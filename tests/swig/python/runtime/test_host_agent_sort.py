import pytest
from unittest import TestCase
from pyflamegpu import *
import random as rand

"""
Dual agent variable sorting is not exposed in pyflamegpu and as such the tests have been removed
"""

AGENT_COUNT = 1024

class sort_ascending_float(pyflamegpu.HostFunctionCallback):
    def __init__(self):
        super().__init__()

    def run(self, FLAMEGPU):
        FLAMEGPU.agent("agent").sortFloat("float", pyflamegpu.HostAgentInstance.Asc)
        
class sort_descending_float(pyflamegpu.HostFunctionCallback):
    def __init__(self):
        super().__init__()

    def run(self, FLAMEGPU):
        FLAMEGPU.agent("agent").sortFloat("float",  pyflamegpu.HostAgentInstance.Desc)
    
class sort_ascending_int(pyflamegpu.HostFunctionCallback):
    def __init__(self):
        super().__init__()

    def run(self, FLAMEGPU):
        FLAMEGPU.agent("agent").sortInt("int",  pyflamegpu.HostAgentInstance.Asc)
   
class sort_descending_int(pyflamegpu.HostFunctionCallback):
    def __init__(self):
        super().__init__()

    def run(self, FLAMEGPU):
        FLAMEGPU.agent("agent").sortInt("int",  pyflamegpu.HostAgentInstance.Desc)

class HostAgentSort(TestCase):

    def test_ascending_float(self): 
        # Define model
        model = pyflamegpu.ModelDescription("model")
        agent = model.newAgent("agent")
        agent.newVariableFloat("float")
        agent.newVariableInt("spare")
        func = sort_ascending_float()
        model.newLayer().addHostFunctionCallback(func)
        rand.seed(a=31313131)
        # Init pop
        pop = pyflamegpu.AgentPopulation(agent, AGENT_COUNT)
        for i in range(AGENT_COUNT): 
            instance = pop.getNextInstance()
            t = rand.uniform(1, 1000000)
            instance.setVariableFloat("float", t)
            instance.setVariableInt("spare", int(t)+12)
        
        # Setup Model
        cuda_model = pyflamegpu.CUDAAgentModel(model)
        cuda_model.setPopulationData(pop)
        # Execute step fn
        cuda_model.step()
        # Check results
        cuda_model.getPopulationData(pop)
        assert AGENT_COUNT == pop.getCurrentListSize()
        prev = 1
        for i in range(AGENT_COUNT): 
            instance = pop.getInstanceAt(i)
            f = instance.getVariableFloat("float")
            s = instance.getVariableInt("spare")
            # Agent variables are still aligned
            assert int(f)+12 == s
            # Agent variables are ordered
            assert f >= prev
            # Store prev
            prev = f
        
"""
    def test_Descending_float(self): 
        # Define model
        model = pyflamegpu.ModelDescription("model")
        agent = model.newAgent("agent")
        agent.newVariableFloat("float")
        agent.newVariableInt("spare")
        model.newLayer().addHostFunction(sort_descending_float)
        std::mt19937 rd(888)  # Fixed seed (at Pete's request)
        std::uniform_real_distribution Float dist(1, 1000000)

        # Init pop
        pop = pyflamegpu.AgentPopulation(agent, AGENT_COUNT)
        for i in range(AGENT_COUNT): 
            instance = pop.getNextInstance()
            const float t = dist(rd)
            instance.setVariableFloat("float", t)
            instance.setVariableInt("spare", static_castInt(t+12))
        
        # Setup Model
        cuda_model = pyflamegpu.CUDAAgentModel(model)
        cuda_model.setPopulationData(pop)
        # Execute step fn
        cuda_model.step()
        # Check results
        cuda_model.getPopulationData(pop)
        assert AGENT_COUNT == pop.getCurrentListSize()
        float prev = 1000000
        for i in range(AGENT_COUNT): 
            instance = pop.getInstanceAt(i)
            const float f = instance.getVariableFloat("float")
            const int s = instance.getVariableInt("spare")
            # Agent variables are still aligned
            assert static_castInt(f+12) == s
            # Agent variables are ordered
            EXPECT_LE(f, prev)
            # Store prev
            prev = f
        

    def test_Ascending_int(self): 
        # Define model
        model = pyflamegpu.ModelDescription("model")
        agent = model.newAgent("agent")
        agent.newVariableInt("int")
        agent.newVariableInt("spare")
        model.newLayer().addHostFunction(sort_ascending_int)
        std::mt19937 rd(77777)  # Fixed seed (at Pete's request)
        std::uniform_int_distribution Int dist(0, 1000000)

        # Init pop
        pop = pyflamegpu.AgentPopulation(agent, AGENT_COUNT)
        for i in range(AGENT_COUNT): 
            instance = pop.getNextInstance()
            const int t = i == AGENT_COUNT/2 ? 0 : dist(rd)  # Ensure zero is output atleast once
            instance.setVariableInt("int", t)
            instance.setVariableInt("spare", t+12)
        
        # Setup Model
        cuda_model = pyflamegpu.CUDAAgentModel(model)
        cuda_model.setPopulationData(pop)
        # Execute step fn
        cuda_model.step()
        # Check results
        cuda_model.getPopulationData(pop)
        assert AGENT_COUNT == pop.getCurrentListSize()
        int prev = 0
        for i in range(AGENT_COUNT): 
            instance = pop.getInstanceAt(i)
            const int f = instance.getVariableInt("int")
            const int s = instance.getVariableInt("spare")
            # Agent variables are still aligned
            assert s-f == 12
            # Agent variables are ordered
            assert f >= prev
            # Store prev
            prev = f
        

    def test_Descending_int(self): 
        # Define model
        model = pyflamegpu.ModelDescription("model")
        agent = model.newAgent("agent")
        agent.newVariableInt("int")
        agent.newVariableInt("spare")
        model.newLayer().addHostFunction(sort_descending_int)
        std::mt19937 rd(12)  # Fixed seed (at Pete's request)
        std::uniform_int_distribution Int dist(1, 1000000)

        # Init pop
        pop = pyflamegpu.AgentPopulation(agent, AGENT_COUNT)
        for i in range(AGENT_COUNT): 
            instance = pop.getNextInstance()
            const int t = dist(rd)
            instance.setVariableInt("int", t)
            instance.setVariableInt("spare", t+12)
        
        # Setup Model
        cuda_model = pyflamegpu.CUDAAgentModel(model)
        cuda_model.setPopulationData(pop)
        # Execute step fn
        cuda_model.step()
        # Check results
        cuda_model.getPopulationData(pop)
        assert AGENT_COUNT == pop.getCurrentListSize()
        int prev = 1000000
        for i in range(AGENT_COUNT): 
            instance = pop.getInstanceAt(i)
            const int f = instance.getVariableInt("int")
            const int s = instance.getVariableInt("spare")
            # Agent variables are still aligned
            assert s-f == 12
            # Agent variables are ordered
            EXPECT_LE(f, prev)
            # Store prev
            prev = f
        
"""

