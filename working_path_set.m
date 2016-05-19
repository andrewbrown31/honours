function working_path = working_path_set(machine)
if strcmp(machine,'laptop')
    working_path = 'F:\working';
end
if strcmp(machine,'desktop')
    working_path = '\media\andrewb1@student.unimelb.edu.au\Elements\working';
end
end