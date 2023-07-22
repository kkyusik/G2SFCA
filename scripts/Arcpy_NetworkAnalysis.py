# written in Python 3.7 

import arcpy
import os

# Output file name configuration
## CostMatrix_Time_{networktime}_{cutoff}_{origin_id}_{order}.txt

# origin_file = 'TOT_REG_CD_01'
# network_time = '01'
# cutoff_number = 16


workspace = r"path.gdb" # set path of gdb
output_folder = r"" # set output_folder


def do_network_analysis(origin_file, network_time, cutoff_number, workspace, output_folder):
    # Set up the environment
    # cutoff_number: time? or count?
    arcpy.env.overwriteOutput = True
    arcpy.CheckOutExtension("network")

    # Define variables.
    destination_feature = 'hospital_max'
    output_txt = 'CostMatrix_Time_' + network_time + '_' + str(cutoff_number) + '_' + origin_file + '.txt'

    workspace = workspace
    arcpy.env.workspace = workspace
    output_folder = output_folder # output folder
    nds = os.path.join(workspace, "Netx", "Netx_ND")
    origins = os.path.join(workspace, origin_file)
    destinations = os.path.join(workspace, destination_feature)
    analysis_layer_name = "OD_" + network_time + '_' + origin_file
    outTable = os.path.join(output_folder, output_txt)

    # Create a new OD cost matrix layer.
    impedance = 'time_' + network_time
    cutoff = cutoff_number
    accumulate = ['time_'+network_time]

    make_layer_result = arcpy.na.MakeODCostMatrixLayer(in_network_dataset=nds,
                                                       out_network_analysis_layer=analysis_layer_name,
                                                       impedance_attribute=impedance,
                                                       default_cutoff=cutoff,
                                                       accumulate_attribute_name=accumulate,
                                                       output_path_shape="NO_LINES")
    analysis_layer = make_layer_result.getOutput(0)

    # Add origins and destinations to the analysis layer using default field mappings.
    sub_layer_names = arcpy.na.GetNAClassNames(analysis_layer)
    origin_layer_name = sub_layer_names['Origins']
    destination_layer_name = sub_layer_names['Destinations']

    ## Add location of origins.
    field_mappings = arcpy.na.NAClassFieldMappings(analysis_layer, origin_layer_name, True)
    field_mappings["Name"].mappedFieldName = "TOT_REG_CD" # id of origins
    arcpy.na.AddLocations(in_network_analysis_layer=analysis_layer,
                          sub_layer=origin_layer_name,
                          in_table=origins,
                          field_mappings=field_mappings,
                          search_tolerance="5000 Meters")
    ## Add location of destinations.
    field_mappings = arcpy.na.NAClassFieldMappings(analysis_layer, destination_layer_name, True)
    field_mappings["Name"].mappedFieldName = "id" # id of destinations
    arcpy.na.AddLocations(in_network_analysis_layer=analysis_layer,
                          sub_layer=destination_layer_name,
                          in_table=destinations,
                          field_mappings=field_mappings,
                          search_tolerance="5000 Meters")

    # Solve.
    print("Start solve of TIME " + network_time + ' of ' + origin_file)
    arcpy.na.Solve(analysis_layer,
                   ignore_invalids='SKIP',
                   terminate_on_solve_error='CONTINUE')

    # Export Table file
    ## Get the sublayers (ODLines) of the layer.
    LinesSubLayer = arcpy.na.GetNASublayer(analysis_layer, 'ODLines')  # ArcGIS Pro version
    # subLayers = dict((lyr.datasetName, lyr) for lyr in arcpy.mapping.ListLayers(analysis_layer)[1:])
    # LinesSubLayer = subLayers["ODLines"]

    ## Export ODLines to txt file.
    arcpy.CopyRows_management(LinesSubLayer, outTable)

    # Export layer file
    #output_layer_file = os.path.join(output_folder, analysis_layer_name + ".lyr")
    #analysis_layer.saveACopy(output_layer_file)

    print("Solve completed with TIME " + network_time + ' of ' + origin_file)

    del analysis_layer
    del make_layer_result


# Execution
time_variable_list = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13',
                      '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', 'max']

## Make origin file list
origin_id = 'TOT_REG_CD_'
origin_file_list = []
origin_file_numbers = 10
for i in range(0, origin_file_numbers):
    origin_file_name = origin_id + str(i+1)
    origin_file_list.append(origin_file_name)

for time_variable in time_variable_list:
    for origin_file in origin_file_list:
        do_network_analysis(origin_file=origin_file, 
                            network_time=time_variable, 
                            cutoff_number=16, 
                            workspace=workspace, 
                            output_folder=output_folder) # 16 # why 999?

