import pytest
from unittest import TestCase
from pyflamegpu import *
import random as rand

TEST_LEN = 256
AGENT_COUNT = 5

# @note seeds 0 and 1 conflict with std::linear_congruential_engine, the default on GCC so using mt19937 to avoid this.
args_1 =  ["process.exe", "-r", "0", "-s", "1" ]
args_2 =  ["process.exe", "-r", "1", "-s", "1" ]

# limits

INT16_MAX = 32767
INT32_MAX = 2147483647
INT64_MAX = 9223372036854775807
UINT16_MAX = int("0xffff", 16)
UINT32_MAX = int("0xffffffff", 16)
UINT64_MAX = int("0xffffffffffffffff",16)

class step_func(pyflamegpu.HostFunctionCallback):
    def __init__(self, function, Type, arga, argb):
        """
        arga and argb mayebe either min/max or mena/stdv
        """
        super().__init__()
        self.Type = Type
        self.function = function
        self.reset_out()
        self.arga = arga
        self.argb = argb

    def reset_out(self):
        self.out = [0] * TEST_LEN

    def run(self, FLAMEGPU):
        for i in range(TEST_LEN):
            rand_func = getattr(FLAMEGPU.random, f"{self.function}{self.Type}")
            # call the typed function and expect no throws
            if self.arga is not None and self.argb is not None:
                self.out[i] = rand_func(self.arga, self.argb)
            else:
                self.out[i] = rand_func()
            
    def assert_zero(self):
        # expect all values to be 0
        for i in range(TEST_LEN):
            assert self.out[i] == 0
            
    def assert_diff_zero(self):
        diff = 0
        for i in range(TEST_LEN):
            if self.out[i] != 0:
                diff += 1
        # expect at least one difference
        assert diff > 0
        
    def assert_diff_all(self):
        diff = 0
        for i in range(TEST_LEN):
            for j in range(TEST_LEN):
                if i != j:  
                    if self.out[i] != self.out[j]:
                        diff += 1
        # expect at least one difference
        assert diff > 0
        
    def assert_diff_list(self, other):
        diff = 0
        for i in range(TEST_LEN):
            if self.out[i] != other[i]:
                diff += 1
        # expect at least one difference
        assert diff > 0
        
    def assert_diff_same(self, other):
        diff = 0
        for i in range(TEST_LEN):
            if self.out[i] != other[i]:
                diff += 1
        # expect at least one difference
        assert diff == 0

"""
FLAMEGPU_STEP_FUNCTION(step_uniform_uchar_range) 
    for (auto i : unsigned_char_out)
        ASSERT_NO_THROW(i = FLAMEGPU.random.uniform<unsigned char>(
            static_cast<unsigned char>(UCHAR_MAX * 0.25),
            static_cast<unsigned char>(UCHAR_MAX * 0.75)))
}
FLAMEGPU_STEP_FUNCTION(step_uniform_char_range) 
    for (char i : char_out)
        ASSERT_NO_THROW(i = FLAMEGPU.random.uniform<char>(
            static_cast<char>(CHAR_MIN * 0.5),
            static_cast<char>(CHAR_MAX * 0.5)))
}
FLAMEGPU_STEP_FUNCTION(step_uniform_ushort_range) 
    for (auto i : unsigned_short_out)
        ASSERT_NO_THROW(i = FLAMEGPU.random.uniform<uint16_t>(
            static_cast<uint16_t>(UINT16_MAX * 0.25),
            static_cast<uint16_t>(UINT16_MAX * 0.75)))
}
FLAMEGPU_STEP_FUNCTION(step_uniform_short_range) 
    for (auto i : short_out)
        ASSERT_NO_THROW(i = FLAMEGPU.random.uniform<int16_t>(
            static_cast<int16_t>(INT16_MIN * 0.5),
            static_cast<int16_t>(INT16_MAX * 0.5)))
}
FLAMEGPU_STEP_FUNCTION(step_uniform_uint_range) 
    for (auto i : unsigned_int_out)
        ASSERT_NO_THROW(i = FLAMEGPU.random.uniform<unsigned int>(
            static_cast<unsigned int>(UINT_MAX * 0.25),
            static_cast<unsigned int>(UINT_MAX * 0.75)))
}
FLAMEGPU_STEP_FUNCTION(step_uniform_int_range) 
    for (auto i : int_out)
        ASSERT_NO_THROW(i = FLAMEGPU.random.uniform<int>(
            static_cast<int>(INT_MIN * 0.5),
            static_cast<int>(INT_MAX * 0.5)))
}
FLAMEGPU_STEP_FUNCTION(step_uniform_ulonglong_range) 
    for (auto i : unsigned_longlong_out)
        ASSERT_NO_THROW(i = FLAMEGPU.random.uniform<uint64_t>(
            static_cast<uint64_t>(UINT64_MAX * 0.25),
            static_cast<uint64_t>(UINT64_MAX * 0.75)))
}
FLAMEGPU_STEP_FUNCTION(step_uniform_longlong_range) 
    for (auto i : longlong_out)
        ASSERT_NO_THROW(i = FLAMEGPU.random.uniform<int64_t>(
            static_cast<int64_t>(INT64_MIN >> 1),
            static_cast<int64_t>(INT64_MAX >> 1)))
}

"""


class MiniSim():

    def __init__(self):
        self.model = pyflamegpu.ModelDescription("model")
        self.agent = self.model.newAgent("agent")
        self.ed = self.model.Environment()
        self.population = pyflamegpu.AgentPopulation(self.agent, TEST_LEN)
        for i in range(AGENT_COUNT):
            instance = self.population.getNextInstance()
    
    def run(self, args): 
        self.cuda_model = pyflamegpu.CUDAAgentModel(self.model)
        self.cuda_model.SimulationConfig().steps = 1
        self.cuda_model.setPopulationData(self.population)
        if len(args) > 0:
            self.cuda_model.initialise(args)
        
        self.cuda_model.simulate()
        # The negative of this, is that cuda_model is inaccessible within the test!
        # So copy across population data here
        self.cuda_model.getPopulationData(self.population)
        
    def rand_test(self, function, Type, min=None, max=None):
        """
        Main contexts of tests are parameterised in this function by random function type (normal/uniform) and the variable type
        """
        step = step_func(function, Type, min, max)
        self.model.addStepFunctionCallback(step)
        # Initially 0
        step.assert_zero()
        # Seed RNG
        self.run(args_1)
        # Value has changed
        step.assert_diff_zero()
        # Multiple calls == different values
        step.assert_diff_all()
        _out = step.out.copy()
        # reset out
        step.reset_out()
        # Different Seed
        self.run(args_2)
        # Value has changed
        step.assert_diff_zero
        # New Seed == new sequence
        step.assert_diff_list(_out)
        # reset
        step.reset_out()
        # First Seed
        self.run(args_1)
        # Value has changed
        step.assert_diff_zero()
        # Old Seed == old values
        step.assert_diff_same(_out)
        

class HostRandomTest(TestCase):

    def test_uniform_float(self):
        ms = MiniSim()
        ms.rand_test("uniform", "Float")
        
    def test_uniform_double(self):
        ms = MiniSim()
        ms.rand_test("uniform", "Double")
        
    def test_normal_float(self):
        ms = MiniSim()
        ms.rand_test("normal", "Float")
        
    def test_normal_double(self):
        ms = MiniSim()
        ms.rand_test("normal", "Double")
        
    def test_lognormal_float(self):
        ms = MiniSim()
        ms.rand_test("logNormal", "Float", 0, 1)
        
    def test_lognormal_double(self):
        ms = MiniSim()
        ms.rand_test("logNormal", "Double", 0, 1)
        
    def test_uniform_Int16(self):
        ms = MiniSim()
        ms.rand_test("uniform", "Int16", 0, INT16_MAX)
        
    def test_uniform_Int32(self):
        ms = MiniSim()
        ms.rand_test("uniform", "Int32", 0, INT32_MAX)
        
    def test_uniform_Int64(self):
        ms = MiniSim()
        ms.rand_test("uniform", "Int64", 0, INT64_MAX)
        
    def test_uniform_UInt16(self):
        ms = MiniSim()
        ms.rand_test("uniform", "UInt16", 0, UINT16_MAX)
        
    def test_uniform_UInt32(self):
        ms = MiniSim()
        ms.rand_test("uniform", "UInt32", 0, UINT32_MAX)
        
    def test_uniform_UInt64(self):
        ms = MiniSim()
        ms.rand_test("uniform", "UInt64", 0, UINT64_MAX)

"""


/**
 * Range tests
 */
TEST_F(HostRandomTest, UniformFloatRange) 
    ms.model.addStepFunction(step_uniform_float)
    ms.run()
    for (auto i : float_out) 
        EXPECT_GE(i, 0.0f)
        EXPECT_LT(i, 1.0f)
    }
}
TEST_F(HostRandomTest, UniformDoubleRange) 
    ms.model.addStepFunction(step_uniform_double)
    ms.run()
    for (auto i : double_out) 
        EXPECT_GE(i, 0.0f)
        EXPECT_LT(i, 1.0f)
    }
}

TEST_F(HostRandomTest, UniformUCharRange) 
    ms.model.addStepFunction(step_uniform_uchar_range)
    ms.run()
    for (auto i : unsigned_char_out) 
        EXPECT_GE(i, static_cast<unsigned char>(UCHAR_MAX*0.25))
        EXPECT_LE(i, static_cast<unsigned char>(UCHAR_MAX*0.75))
    }
}
TEST_F(HostRandomTest, UniformCharRange) 
    ms.model.addStepFunction(step_uniform_char_range)
    ms.run()
    for (auto i : unsigned_char_out) 
        EXPECT_GE(i, static_cast<char>(CHAR_MIN*0.5))
        EXPECT_LE(i, static_cast<char>(CHAR_MAX*0.5))
    }
}

TEST_F(HostRandomTest, UniformUShortRange) 
    ms.model.addStepFunction(step_uniform_ushort_range)
    ms.run()
    for (auto i : unsigned_short_out) 
        EXPECT_GE(i, static_cast<uint16_t>(UINT16_MAX*0.25))
        EXPECT_LE(i, static_cast<uint16_t>(UINT16_MAX*0.75))
    }
}
TEST_F(HostRandomTest, UniformShortRange) 
    ms.model.addStepFunction(step_uniform_short_range)
    ms.run()
    for (auto i : short_out) 
        EXPECT_GE(i, static_cast<int16_t>(INT16_MIN*0.5))
        EXPECT_LE(i, static_cast<int16_t>(INT16_MAX*0.5))
    }
}

TEST_F(HostRandomTest, UniformUIntRange) 
    ms.model.addStepFunction(step_uniform_uint_range)
    ms.run()
    for (auto i : unsigned_int_out) 
        EXPECT_GE(i, static_cast<unsigned int>(UINT_MAX*0.25))
        EXPECT_LE(i, static_cast<unsigned int>(UINT_MAX*0.75))
    }
}
TEST_F(HostRandomTest, UniformIntRange) 
    ms.model.addStepFunction(step_uniform_int_range)
    ms.run()
    for (auto i : int_out) 
        EXPECT_GE(i, static_cast<int>(INT_MIN*0.5))
        EXPECT_LE(i, static_cast<int>(INT_MAX*0.5))
    }
}

TEST_F(HostRandomTest, UniformULongLongRange) 
    ms.model.addStepFunction(step_uniform_ulonglong_range)
    ms.run()
    for (auto i : unsigned_longlong_out) 
        EXPECT_GE(i, static_cast<uint64_t>(UINT64_MAX*0.25))
        EXPECT_LE(i, static_cast<uint64_t>(UINT64_MAX*0.75))
    }
}
TEST_F(HostRandomTest, UniformLongLongRange) 
    ms.model.addStepFunction(step_uniform_longlong_range)
    ms.run()
    for (auto i : longlong_out) 
        EXPECT_GE(i, static_cast<int64_t>(INT64_MIN >> 1))
        EXPECT_LE(i, static_cast<int64_t>(INT64_MAX >> 1))
    }
}

"""

