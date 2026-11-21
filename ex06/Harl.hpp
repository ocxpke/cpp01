#ifndef HARL_HPP
# define HARL_HPP

# include <string>

class Harl
{
public:
	Harl(void);
	~Harl(void);

	void	filter(std::string level);

private:
	void	debug(void);
	void	info(void);
	void	warning(void);
	void	error(void);

	static int	_getLevelIndex(const std::string &level);
};

#endif
