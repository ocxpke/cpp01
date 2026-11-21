#include "replace.hpp"
#include <iostream>
#include <string>

int	main(int argc, char **argv)
{
	if (argc != 4)
	{
		std::cerr << "Usage: " << argv[0] << " <filename> <s1> <s2>"
				  << std::endl;
		return (1);
	}
	if (std::string(argv[2]).empty())
	{
		std::cerr << "Error: s1 can't be empty" << std::endl;
		return (1);
	}
	return (replaceInFile(argv[1], argv[2], argv[3]));
}
