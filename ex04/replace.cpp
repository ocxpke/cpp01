#include "replace.hpp"
#include <iostream>
#include <fstream>
#include <sstream>

/**
 * @brief Builds a new string replacing every s1 of content by s2
 *
 * @note std::string::replace is forbidden, so the result is built
 * by copying the text between the matches and adding s2 instead of s1.
 * The search continues after the match, so if s2 contains s1 there
 * is no infinite loop
 *
 * @param content Original text
 * @param s1 String to search, must not be empty
 * @param s2 String to put instead of s1
 * @return std::string The text with the replacements
 */
std::string	replaceAll(const std::string &content, const std::string &s1,
				const std::string &s2)
{
	std::string	result;
	size_t		start;
	size_t		found;

	start = 0;
	found = content.find(s1, start);
	while (found != std::string::npos)
	{
		/* Write all text before s1*/
		result += content.substr(start, found - start);
		/* Write s2 */
		result += s2;
		/* Jump in original text s1*/
		start = found + s1.length();
		/* Find the next s1*/
		found = content.find(s1, start);
	}
	/* Copy all that remains*/
	result += content.substr(start);
	return (result);
}

/**
 * @brief Reads filename, replaces every s1 by s2 and writes the
 * result in filename.replace
 *
 * @note rdbuf() reads the whole file at once, keeping the newlines
 * exactly as they are (getline would lose the last one)
 *
 * @param filename File to read
 * @param s1 String to search
 * @param s2 String to put instead of s1
 * @return int 0 if everything went ok, 1 if there was an error
 */
int	replaceInFile(const std::string &filename, const std::string &s1,
		const std::string &s2)
{
	std::ifstream		infile;
	std::ofstream		outfile;
	std::stringstream	buffer;

	infile.open(filename.c_str());
	if (!infile.is_open())
	{
		std::cerr << "Error: can't open " << filename << std::endl;
		return (1);
	}
	/* Tries to read 1 byte, if read fails this means that we are on a directory*/
	infile.peek();
	if (infile.bad())
	{
		std::cerr << "Error: can't read " << filename << std::endl;
		return (1);
	}
	buffer << infile.rdbuf();
	infile.close();
	outfile.open((filename + ".replace").c_str());
	if (!outfile.is_open())
	{
		std::cerr << "Error: can't create " << filename << ".replace"
				  << std::endl;
		return (1);
	}
	outfile << replaceAll(buffer.str(), s1, s2);
	outfile.close();
	return (0);
}
