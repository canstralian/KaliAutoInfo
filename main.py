import pytest
print(pytest.main(["-v", "test_name_split.py"]))
print(pytest.main(["-v", "test_name_split.py::test_split_name"]))
print(pytest.main(["-v", "test_name_split.py::test_split_name::test_split_name_1"]))
print(pytest.main(["-v", "test_name_split.py::test_split_name::test_split_name_2"]))
print(pytest.main(["-v", "test_name_split.py::test_split_name::test_split_name_3"]))

# # # Sample Tests
# # import pytest
# # 
# # 
# # @pytest.mark.parametrize("name, expected", [
# #     ("John Smith", ["John", "Smith"]),
# #     ("Jane Doe", ["Jane", "Doe"]),
# #     ("Jane Smith", ["Jane", "Smith"]),
# #     ("Jane Smith Jr.", ["Jane", "Smith"]),
# #     ("Jane Smith, Jr.", ["Jane  
# # 
# # 
# # 
# # 

# # # Sample Tests
# # import pytest
# # 
# # 
# # @pytest.mark.parametrize("name, expected", [
# #     ("John Smith", ["John", "Smith"]),
# #     ("Jane Doe", ["Jane", "Doe"]),
# #     ("Jane Smith", ["Jane", "Smith"]),
# #     ("Jane Smith Jr.", ["Jane", "Smith"]),
# #     ("Jane Smith, Jr.", ["Jane  
# # 