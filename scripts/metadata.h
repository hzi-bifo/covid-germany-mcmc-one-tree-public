#include <ctime>

double date_to_year(string date) {
	std::tm t = {};
	strptime(date.c_str(), "%Y-%m-%d", &t);

	std::tm tm_year = t;
	tm_year.tm_mday = 1;
	tm_year.tm_mon = 0;

	std::tm tm_year_next = tm_year;
	tm_year_next.tm_year++;

	auto year_second = difftime(mktime(&tm_year_next), mktime(&tm_year));
	auto second_from_year_start = difftime(mktime(&t), mktime(&tm_year));
	double res = second_from_year_start / year_second;
	//cerr << asctime(&t) << endl;
	return 1900 + t.tm_year + res;
}

string year_to_date(double year) {
	std::tm t{};
	t.tm_year = int(year) - 1900;
	t.tm_mday = 1;

	tm nt = t;
	nt.tm_year++;

	int year_second = difftime(mktime(&nt), mktime(&t));
	t.tm_sec = int((year - int(year)) * year_second);

	time_t t_ = mktime(&t);
	char buff[100];
	tm* t_tm = localtime(&t_);
	strftime(buff, 100, "%Y-%m-%d", t_tm);
	return buff;
}
