#include "Weapon.hpp"

/**
 * @brief Constructor, sets the type of the weapon
 *
 * @param type Type of the weapon
 */
Weapon::Weapon(std::string type) : _type(type)
{
}

/**
 * @brief Destructor, nothing to free
 */
Weapon::~Weapon(void)
{
}

/**
 * @brief Getter of the type
 *
 * @note It returns a const reference: no copy is made and
 * the caller can't modify the type through it
 *
 * @return const std::string& Type of the weapon
 */
const std::string	&Weapon::getType(void) const
{
	return (_type);
}

/**
 * @brief Setter of the type
 *
 * @param type New type of the weapon
 */
void	Weapon::setType(std::string type)
{
	_type = type;
}
