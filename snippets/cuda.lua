return {
	st = [[
#include <iostream>

int main (int argc, char *argv[]) {
	$1

	return 0;
}]],
	["for"] = [[
for (${1:size_t} ${2:i} = ${3:0}; $2 < ${4:length}; $2++) {
	$0
}]],
	forr = [[
for (${1:size_t} ${2:i} = ${3:length} - 1; $2 >= ${4:0}; $2--) {
	$0
}]],
	["do"] = [[
do {
	$0
} while($1);]],
	["while"] = [[
while ($1) {
	$2
}]],
	foreach = [[
for(${1:auto} ${2:var} : ${3:collection_to_loop}) {
	$0
}]],
	["if"] = [[
if ($1) {
	$0
}]],
	["else"] = [[
else {
	$0
}]],
	elif = [[
else if ($1) {
	$0
}]],
	enum = [[
enum ${1:MyEnum} {
	$0
};]],
	enumclass = [[
enum class ${1:MyClass} {$0};]],
	class = [[
class ${1:MyClass} {
public:
	$1();
	$1($1 &&) = default;
	$1(const $1 &) = default;
	$1 &operator=($1 &&) = default;
	$1 &operator=(const $1 &) = default;
	~$1();

private:
	$2
};

$1::$1() {
}

$1::~$1() {
}]],
	eclass = [[
class ${1:MyClass} {
public:
	$2
private:
	$3
};
]],
	qclass = [[
class ${1:MyClass} : public QObject {
	Q_OBJECT;
public:

explicit $1(QObject *parent = nullptr);
	$2
signals:

public slots:
};
]],
	classi = [[
class ${1:MyClass} {
public:
	$1() = default;
	$1($1 &&) = default;
	$1(const $1 &) = default;
	$1 &operator=($1 &&) = default;
	$1 &operator=(const $1 &) = default;
	~$1() = default;

private:
	$2
};]],
	interface = [[
__interface I${1:Interface} {
	$0
};]],
	namespace = [[
namespace ${1:MyNamespace} {
	$0
}]],
	ifdef = [[
#ifdef ${1:DEBUG}
$0
#endif // ${DEBUG}]],
	ifndef = [[
#ifndef ${1:DEBUG}
$0
#endif // !$1]],
	ifpp = [[
#if ${1:0}
$0
#endif // $1]],
	struct = [[
struct ${1:MyStruct} {
	$0
};]],
	switch = [[
switch (${1:switch_on}) {
	default:
		$0
		break;
}]],
	try = [[
try {
	$2
}
catch (${1:const std::exception&}) {
}]],
	union = [[
union ${1:MyUnion} {
	$0
};]],
	cout = [[
std::cout << ${1:message};]],
	cin = [[
std::cin >> $1;]],
	printf = [[
printf("$1\n"$0);]],
	sprintf = [[
sprintf($1, "$2\n"$0);]],
	fprintf = [[
fprintf(${1:stderr}, "$2\n"$0);]],
	scanf = [[
scanf("$1"$0);]],
	sscanf = [[
sscanf($1, "$2"$0);]],
	fscanf = [[
fscanf($1, "$2"$0);]],
	inc = [[
#include "$1"$2]],
	incs = [[
#include <$1>$2]],
	def = [[
#define $0]],
	main = [[
int main (int argc, char *argv[]) {
	$1
	return 0;
}]],
	guard = [[
#ifndef INCLUDE${TM_DIRECTORY/.*[\/](.*)/_${1:/upcase}/}${TM_FILENAME_BASE/(.*)/_${1:/upcase}/}${TM_FILENAME/.*\.(.*)/_${1:/upcase}/}_
#define INCLUDE${TM_DIRECTORY/.*[\/](.*)/_${1:/upcase}/}${TM_FILENAME_BASE/(.*)/_${1:/upcase}/}${TM_FILENAME/.*\.(.*)/_${1:/upcase}/}_

$0

#endif  // INCLUDE${TM_DIRECTORY/.*[\/](.*)/_${1:/upcase}/}${TM_FILENAME_BASE/(.*)/_${1:/upcase}/}${TM_FILENAME/.*\.(.*)/_${1:/upcase}/}_]],
	sca = [[
static_cast<${1:unsigned}>(${2:expr})$3]],
	dca = [[
dynamic_cast<${1:unsigned}>(${2:expr})$3]],
	rca = [[
reinterpret_cast<${1:unsigned}>(${2:expr})$3]],
	cca = [[
const_cast<${1:unsigned}>(${2:expr})$3]],
	af = [[
auto ${1:name}( ${2:void} ) -> ${3:auto} {
	${5}
}]],
}
