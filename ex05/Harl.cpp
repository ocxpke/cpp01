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
	std::cout << "I love having extra bacon for my "
			  << "7XL-double-cheese-triple-pickle-special-ketchup burger. "
			  << "I really do!" << std::endl;
}

/**
 * @brief INFO level message
 */
void	Harl::info(void)
{
	std::cout << "I cannot believe adding extra bacon costs more money. "
			  << "You didn't put enough bacon in my burger! "
			  << "If you did, I wouldn't be asking for more!" << std::endl;
}

/**
 * @brief WARNING level message
 */
void	Harl::warning(void)
{
	std::cout << "I think I deserve to have some extra bacon for free. "
			  << "I've been coming for years, whereas you started working "
			  << "here just last month." << std::endl;
}

/**
 * @brief ERROR level message
 */
void	Harl::error(void)
{
	std::cout << "This is unacceptable! I want to speak to the manager now."
			  << std::endl;
}

/**
 * @brief Calls the member function that matches the level, without
 * a forest of if/else
 *
 * @note levels[i] and functions[i] go together: the loop finds the
 * index of the level and calls the function at the same index.
 * (this->*functions[i])() calls a pointer to member function on
 * this object. An unknown level does nothing
 *
 * @param level "DEBUG", "INFO", "WARNING" or "ERROR"
 */
void	Harl::complain(std::string level)
{
	const std::string	levels[4] = {"DEBUG", "INFO", "WARNING", "ERROR"};
	void				(Harl::*functions[4])(void) = {
		&Harl::debug,
		&Harl::info,
		&Harl::warning,
		&Harl::error
	};

	for (int i = 0; i < 4; i++)
	{
		if (level == levels[i])
		{
			(this->*functions[i])();
			return ;
		}
	}
}
