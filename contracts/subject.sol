// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract Subject {
    //string public name;
    // string public typeOfSubject;

    // структура данных для преподователей
    struct Teacher {
        address _address;
        bool exist;
    }
    mapping(address => Teacher) public teachers;
    address[] public teachers_list;
    
    // стурктура данных для студентов
    struct Student {
        address _address;
        bool approve;
        bool exist;
    }
    mapping(address => Student) public students;
    address[] public students_list;
    mapping(address => int8[]) public attendance;
    mapping(address => uint8[]) public grades;


    address public admin; 
    uint public nClasses;

    mapping(address => bool) public subjMap;

    modifier adminOnly() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    modifier teacherOnly() {
        require(teachers[msg.sender].exist == true, "Only teacher can call this function");
        _;
    }

    constructor(
        // string memory subjectName, 
        uint _nClasses
    ) {
        // require(
        //     _nClasses > 0,
        //     "The number of classes must be greater than 0."
        // );
        admin = msg.sender;
        // name = subjectName;
        // typeOfSubject = _typeOfSubject;
        nClasses = _nClasses;
    }


    // function getName() public view returns(string memory) {
    //     return name;
    // }


    function addTeacher(address teacher_adr) public adminOnly {
        require(teachers[teacher_adr].exist == false, 
                 "There is already such a subject with this id!");
        teachers[teacher_adr] = Teacher(teacher_adr, true);
        teachers_list.push(teacher_adr);
    }


    function hasTeacher(address teacher_adr) public view {
        teachers[teacher_adr].exist;
    }


    function hasStudent(address student_adr) public view {
        students[student_adr].exist;
    }



    function addStudent(address student_adr) public {
        require(students[student_adr].exist == false, 
                 "There is already such a subject with this id!");
        students[student_adr] = Student(student_adr, false, true);
        students_list.push(student_adr);
    }

    
    function approveStudent(address student_adr) public {
        require((msg.sender == admin) || (teachers[msg.sender].exist == true), 
                 "You must be admin or teacher!");
        require(students[student_adr].exist == true, 
                 "Its not student");
        students[student_adr].approve = true;
        for (uint i = 0; i < nClasses; i++) {
            attendance[student_adr].push(-1);
            grades[student_adr].push(0);
        }
    }


    function disapproveStudent(address student_adr) public {
        require((msg.sender == admin) || (teachers[msg.sender].exist == true), 
                 "You must be admin or student!");
        require(students[student_adr].exist == true, 
                 "Its not student");
        students[student_adr].approve = false;

    }


    function studentIsApproved(address student_adr) public view returns(bool) {
        require(students[student_adr].exist == true, 
                 "");
        return students[student_adr].approve;
    }


    function _shiftByIndex(address[] memory _adrArr, uint _index) private pure {
        require(_index < _adrArr.length, "Out of bound");
        for (uint i = _index; i < _adrArr.length-1; i++) {
            _adrArr[i] = _adrArr[i + 1];
        }
    }


    function delTeacher(address teacher_adr) public {
        require(teachers[teacher_adr].exist == true, 
                 "");
        delete teachers[teacher_adr];

        uint del_index = 0;
        for (uint i = 0; i < teachers_list.length; i++) {
            if (teachers_list[i] == teacher_adr) {
                del_index = i;
                break;
            }
        }
        _shiftByIndex(teachers_list, del_index);
        teachers_list.pop();
    }


    function delStudent(address _student_adr) public {
        require(students[_student_adr].exist == true, 
                 "");
        delete students[_student_adr];

        uint del_index = 0;
        for (uint i = 0; i < students_list.length; i++) {
            if (students_list[i] == _student_adr) {
                del_index = i;
                break;
            }
        }
        _shiftByIndex(students_list, del_index);
        students_list.pop();
    }

    function markVisit(
        address _studentAdr,
        uint _day,
        int8 _mark
    ) public teacherOnly {
        require((students[_studentAdr].exist == true), 
                 "There is no student with this address.");
        require((students[_studentAdr].approve == true), 
                 "Student not approved.");
        require(_day < nClasses, 
                "The day number is greater than the number of classes.");
        require((_mark == 0) || (_mark == 1), "Mark must be 0 or 1.");
        attendance[_studentAdr][_day] = _mark;
    }


    function giveGrade(
        address _studentAdr,
        uint _day,
        uint8 _grade
    ) public teacherOnly {
        require((students[_studentAdr].exist == true), 
                 "There is no student with this address.");
        require((students[_studentAdr].approve == true), 
                 "Student not approved.");
        require(_day < nClasses, 
                "The day number is greater than the number of classes.");
        require((_grade >= 1) || (_grade <= 5), "Grade must be beetween 1 or 5.");
        grades[_studentAdr][_day] = _grade;
    }

    function gradesByStudent(
        address _studentAdr
    ) public view returns (uint8[] memory) {
        require((students[_studentAdr].exist == true), 
                 "There is no student with this address.");
        require((students[_studentAdr].approve == true), 
                 "Student not approved.");
        return grades[_studentAdr];
    }

    function attendanceByStudent(
        address _studentAdr
    ) public view returns (int8[] memory) {
        require((students[_studentAdr].exist == true), 
                 "There is no student with this address.");
        require((students[_studentAdr].approve == true), 
                 "Student not approved.");
        return attendance[_studentAdr];
    }

    function meanGradeByStudent(
         address _studentAdr,
         uint _board
    ) public view returns(uint) {
        require((students[_studentAdr].exist == true), 
                 "There is no student with this address.");
        require((students[_studentAdr].approve == true), 
                 "Student not approved.");
        uint clip_board = _board;
        if (_board > nClasses) {
            clip_board = nClasses;
        }
        uint result = 0;
        uint n_grades = 0;
        for (uint i = 0; i < clip_board; i++) {
            if (grades[_studentAdr][i] !=0) {
                n_grades++;
                result += grades[_studentAdr][i];
            }
        }
        if (n_grades == 0) {
            return 0;
        }
        return result / n_grades;
    }


    function meanGrade(
        uint _board
    ) public view returns(uint) {
        uint clip_board = _board;
        if (_board > nClasses) {
            clip_board = nClasses;
        }
        uint result = 0;
        uint n_apr_students = 0;
        for (uint i = 0; i < students_list.length; i++) {
            if (students[students_list[i]].approve) {
                result += meanGradeByStudent(students_list[i], clip_board);
                n_apr_students++;
            }
        }
        if (n_apr_students == 0) {
            return 0;
        }
        return result / n_apr_students;
    }

    function getNCalsses(
    ) public view returns(uint) {
        return nClasses;
    }

    function getApprovedStudents(
        // uint cursor, 
        // uint length
    ) public view returns(address[] memory) {
        // require(cursor + length < students_list.length, '');
        uint n_approved = 0;
        for (uint i = 0; i < students_list.length; i++) {
            if (students[students_list[i]].approve) {
                n_approved++;
            }
        }
        address[] memory result = new address[](n_approved);
        uint counter = 0;
        for (uint i = 0; i < students_list.length; i++) {
            if (students[students_list[i]].approve) {
                result[counter] = students_list[i];
                counter++;
            }
        }
        return result;
    }
}
