#include "Harl.hpp"
#include <iostream>

/**
 * @brief Constructor, nothing to initialise
 */
Harl::Harl(void)
{
}

/**
 * @brief Destructor, nothing to free
 */
Harl::~Harl(void)
{
}

/**
 * @brief DEBUG level message
 */
void	Harl::debug(void)
{
	std::cout << "[ DEBUG ]" << std::endl
			  << "I love having extra bacon for my "
			  << "7XL-double-cheese-triple-pickle-special-ketchup burger."
			  << std::endl
			  << "I really do!" << std::endl << std::endl;
}

/**
 * @brief INFO level message
 */
void	Harl::info(void)
{
	std::cout << "[ INFO ]" << std::endl
			  << "I cannot believe adding extra bacon costs more money."
			  << std::endl
			  << "You didn't put enough bacon in my burger! "
			  << "If you did, I wouldn't be asking for more!"
			  << std::endl << std::endl;
}

/**
 * @brief WARNING level message
 */
void	Harl::warning(void)
{
	std::cout << "[ WARNING ]" << std::endl
			  << "I think I deserve to have some extra bacon for free."
			  << std::endl
			  << "I've been coming for years, whereas you started working "
			  << "here just last month." << std::endl << std::endl;
}

/**
 * @brief ERROR level message
 */
void	Harl::error(void)
{
	std::cout << "[ ERROR ]" << std::endl
			  << "This is unacceptable! I want to speak to the manager now."
			  << std::endl << std::endl;
}

/**
 * @brief Converts a level name to its index, so it can be used
 * in a switch (switch only works with integers, not strings)
 *
 * @param level Level name
 * @return int 0 to 3 for DEBUG, INFO, WARNING, ERROR, -1 if unknown
 */
int	Harl::_getLevelIndex(const std::string &level)
{
	const std::string	levels[4] = {"DEBUG", "INFO", "WARNING", "ERROR"};

	for (int i = 0; i < 4; i++)
	{
		if (level == levels[i])
			return (i);
	}
	return (-1);
}

/**
 * @brief Prints the messages from the given level and all the
 * levels above it
 *
 * @note There is no break between the cases on purpose: when a case
 * matches, the execution falls through to the next cases, so all the
 * levels above are printed too. The fall through comments tell the
 * compiler it is wanted (-Wextra warns about it in gcc)
 *
 * @param level Minimum level to display
 */
void	Harl::filter(std::string level)
{
	switch (_getLevelIndex(level))
	{
		case 0:
			debug();
			/* fall through */
		case 1:
			info();
			/* fall through */
		case 2:
			warning();
			/* fall through */
		case 3:
			error();
			break ;
		default:
			std::cout << "[ Probably complaining about insignificant problems ]"
					  << std::endl;
	}
}
