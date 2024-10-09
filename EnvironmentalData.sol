// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

enum DBHMeasureUnit { CENTIMETER, METER }
enum HealthStatus { DEAD, CRITICAL, WEAK, HEALTHY }

struct EnvironmentalData {
    uint16 biodiversityIndex; // Índice de biodiversidade (0 a 1000)
    int8 soilPh;              // pH do solo (-14 a +14)
    uint8 soilMoisture;       // Umidade do solo (0 a 100)
    uint8 waterQuality;       // Qualidade da água próxima (0 a 100)
}

struct Intervention {
    string actionDescription; // Descrição da ação (e.g., replantio, irrigação)
    uint timestamp;           // Momento da intervenção
}

struct SilviSpecie {
    uint8 dbhMeasure;            // Diâmetro à altura do peito
    DBHMeasureUnit dbhUnit;      // Unidade da medida (centímetros ou metros)
    bytes32 speciesName;         // Nome da espécie
    int32 latitude;              // Latitude em microdegrees
    int32 longitude;             // Longitude em microdegrees
    HealthStatus healthStatus;   // Estado de saúde atual
    EnvironmentalData envData;   // Dados ambientais
    Intervention[] interventions; // Ações tomadas (intervenções)
}

contract SpeciesMonitoring {
    SilviSpecie[] public speciesList;

    event SpeciesAdded(uint speciesId, bytes32 speciesName);
    event InterventionAdded(uint speciesId, string action, uint timestamp);

    function addSpecies(
        uint8 _dbhMeasure, 
        DBHMeasureUnit _dbhUnit, 
        string memory _speciesName, 
        int32 _latitude, 
        int32 _longitude
    ) public {
        SilviSpecie memory newSpecie = SilviSpecie({
            dbhMeasure: _dbhMeasure,
            dbhUnit: _dbhUnit,
            speciesName: stringToBytes32(_speciesName),
            latitude: _latitude,
            longitude: _longitude,
            healthStatus: HealthStatus.HEALTHY,  // Inicialmente considerada saudável
            envData: EnvironmentalData({
                biodiversityIndex: 0,  // Inicialize com zero, dados atualizados depois
                soilPh: 0,
                soilMoisture: 0,
                waterQuality: 0
            }),
            interventions: new Intervention 
        });

        speciesList.push(newSpecie);
        emit SpeciesAdded(speciesList.length - 1, newSpecie.speciesName);
    }

    function updateHealthStatus(uint speciesId, HealthStatus _newStatus) public {
        SilviSpecie storage specie = speciesList[speciesId];
        specie.healthStatus = _newStatus;
    }

    function addEnvironmentalData(
        uint speciesId, 
        uint16 _biodiversityIndex, 
        int8 _soilPh, 
        uint8 _soilMoisture, 
        uint8 _waterQuality
    ) public {
        SilviSpecie storage specie = speciesList[speciesId];
        specie.envData = EnvironmentalData({
            biodiversityIndex: _biodiversityIndex,
            soilPh: _soilPh,
            soilMoisture: _soilMoisture,
            waterQuality: _waterQuality
        });
    }

    function addIntervention(uint speciesId, string memory _action) public {
        SilviSpecie storage specie = speciesList[speciesId];
        specie.interventions.push(Intervention({
            actionDescription: _action,
            timestamp: block.timestamp
        }));

        emit InterventionAdded(speciesId, _action, block.timestamp);
    }

    // Utility function to convert string to bytes32
    function stringToBytes32(string memory source) internal pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        // Truncate the string if it's longer than 32 characters
        assembly {
            result := mload(add(source, 32))
        }
    }
}
