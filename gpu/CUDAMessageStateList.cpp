 /**
 * @file CUDAMessageStateList.cpp
 * @authors
 * @date
 * @brief
 *
 * @see
 * @warning Not done, will not compile
 */

#include <cuda_runtime.h>
#include <device_launch_parameters.h>

#include "CUDAMessageStateList.h"

#include "CUDAMessage.h"
#include "CUDAErrorChecking.h"
#include "../pop/AgentStateMemory.h"
#include "../model/MessageDescription.h"
#include "../pop/AgentPopulation.h"


/**
* CUDAAgentStateList class
* @brief populates CUDA agent map, CUDA message map
*/
CUDAMessageStateList::CUDAMessageStateList(CUDAMessage& cuda_message) : message(cuda_message)
{

    //allocate state lists
    allocateDeviceMessageList(d_list);
    allocateDeviceMessageList(d_swap_list);
    allocateDeviceMessageList(d_new_list);

}

/**
 * A destructor.
 * @brief Destroys the CUDAAgentStateList object
 */
CUDAMessageStateList::~CUDAMessageStateList()
{

}

void CUDAMessageStateList::cleanupAllocatedData()
{
	//clean up
	releaseDeviceMessageList(d_list);
	releaseDeviceMessageList(d_swap_list);
    releaseDeviceMessageList(d_new_list);

}

/**
* @brief Allocates Device  message list
* @param variable of type CUDAAgentMemoryHashMap struct type
* @return none
*/
void CUDAMessageStateList::allocateDeviceMessageList(CUDAMemoryMap &memory_map)
{
	//we use the  messages memory map to iterate the  message variables and do allocation within our GPU hash map
    const VariableMap &mem = message.getMessageDescription().getVariableMap();

    //for each variable allocate a device array and add to map
	for (const VariableMapPair& mm : mem)
    {
		//get the variable name
		std::string var_name = mm.first;

		//get the variable size from  message description
		size_t var_size = message.getMessageDescription().getMessageVariableSize(mm.first);

		//do the device allocation
		void * d_ptr;

#ifdef UNIFIED_GPU_MEMORY
		//unified memory allocation
		gpuErrchk(cudaMallocManaged((void**)&d_ptr, var_size *  message.getMaximumListSize()))
#else
		//non unified memory allocation
		gpuErrchk(cudaMalloc((void**)&d_ptr, var_size * message.getMaximumListSize()));
#endif


		//store the pointer in the map
		memory_map.insert(CUDAMemoryMap::value_type(var_name, d_ptr));
    }

}

/**
* @brief Frees
* @param variable of type CUDAAgentMemoryHashMap struct type
* @return none
*/
void CUDAMessageStateList::releaseDeviceMessageList(CUDAMemoryMap& memory_map)
{
	//for each device pointer in the cuda memory map we need to free these
	for (const CUDAMemoryMapPair& mm : memory_map)
    {
		//free the memory on the device
		gpuErrchk(cudaFree(mm.second));
    }
}

/**
* @brief
* @param variable of type CUDAAgentMemoryHashMap struct type
* @return none
*/
void CUDAMessageStateList::zeroDeviceMessageList(CUDAMemoryMap& memory_map)
{

	//for each device pointer in the cuda memory map set the values to 0
	for (const CUDAMemoryMapPair& mm : memory_map)
	{
		//get the variable size from message description
		size_t var_size = message.getMessageDescription().getMessageVariableSize(mm.first);

		//set the memory to zero
		gpuErrchk(cudaMemset(mm.second, 0, var_size*message.getMaximumListSize()));
	}
}

void* CUDAMessageStateList::getMessageListVariablePointer(std::string variable_name)
{
	CUDAMemoryMap::iterator mm = d_list.find(variable_name);
	if (mm == d_list.end()){
		//TODO: Error variable not found in message list
		return 0;
	}

	return mm->second;
}


void CUDAMessageStateList::zeroMessageData(){
	zeroDeviceMessageList(d_list);
	zeroDeviceMessageList(d_swap_list);
    zeroDeviceMessageList(d_new_list);
}

