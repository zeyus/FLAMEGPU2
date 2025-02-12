#ifndef INCLUDE_FLAMEGPU_IO_XMLSTATEREADER_H_
#define INCLUDE_FLAMEGPU_IO_XMLSTATEREADER_H_

#include <memory>
#include <string>
#include <unordered_map>
#include <utility>

#include "flamegpu/io/StateReader.h"
#include "flamegpu/model/ModelDescription.h"
#include "flamegpu/util/StringPair.h"

namespace flamegpu {
namespace io {
/**
 * XML format StateReader
 */
class XMLStateReader : public StateReader {
 public:
    /**
     * Constructs a reader capable of reading model state from XML files
     * Environment properties will be read into the Simulation instance pointed to by 'sim_instance_id'
     * Agent data will be read into 'model_state'
     * @param model_name Name from the model description hierarchy of the model to be loaded
     * @param env_desc Environment description for validating property data on load
     * @param env_init Dictionary of loaded values map:<{name, index}, value>
     * @param model_state Map of AgentVector to load the agent data into per agent, key should be agent name
     * @param input_file Filename of the input file (This will be used to determine which reader to return)
     * @param sim_instance Instance of the Simulation object (This is used for setting/getting config)
     */
    XMLStateReader(
        const std::string &model_name,
        const std::unordered_map<std::string, EnvironmentData::PropData> &env_desc,
        std::unordered_map<std::string, detail::Any> &env_init,
        util::StringPairUnorderedMap<std::shared_ptr<AgentVector>> &model_state,
        const std::string &input_file,
        Simulation *sim_instance);
    /**
     * Actual performs the XML parsing to load the model state
     * @return Always tinyxml2::XML_SUCCESS
     * @throws exception::TinyXMLError If parsing of the input file fails
     */
    int parse() override;

 private:
    /**
     * Flamegpu1 xml input files are allowed to omit state
     * This function extracts the initial state for the named agent from model_state;
     */
    std::string getInitialState(const std::string& agent_name) const;
};
}  // namespace io
}  // namespace flamegpu

#endif  // INCLUDE_FLAMEGPU_IO_XMLSTATEREADER_H_
