########################################################################################################################
#                                                                                                                      #
#                                   TAD4D attribute for TAD4D Cookbook                                                 #
#                                                                                                                      #
#   Language            : Chef/Ruby                                                                                    #
#   Date                : 01.07.2016                                                                                   #
#   Date Last Update    : 08.09.2016                                                                                   #
#   Version             : 0.1                                                                                          #
#   Author              : Arnaud THALAMOT                                                                              #
#                                                                                                                      #
########################################################################################################################

ibm_tad4d_tad4dagent 'uninstall-TAD4D-agent' do
  action [:uninstall]
end
