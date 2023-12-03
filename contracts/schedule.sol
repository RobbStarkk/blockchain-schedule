// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import {Subject} from "./subject.sol";
// import "github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.0/contracts/utils/structs/EnumerableSet.sol";
import "OpenZeppelin/openzeppelin-contracts@5.0.0/contracts/utils/structs/EnumerableSet.sol";

contract Schedule {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    address supervisor;

    uint[7][6][15] private scheduleTable;  // таблица с расписанием 15 недель по 6 дней и 7 слотов
    
    // Структура для хранения предметов
    struct subjectStruct {
        Subject subject;
        uint id;
        uint[2] day_time;
        bool exist;
    }
    mapping(uint => subjectStruct) private subjects;
    EnumerableSet.UintSet subjects_id_set;

    // Структура для хранения студентов
    struct personStruct {
        // string name;
        uint id;
        EnumerableSet.UintSet subjects_set;
        bool exist;
    }
    // Структура для хранения студентов
    mapping(address => personStruct) students;
    EnumerableSet.AddressSet students_set;
    // EnumerableSet.UintSet students_id_set;

    // Структура для хренения преподователей
    mapping(address => personStruct) teachers;
    EnumerableSet.AddressSet teachers_set;
    // EnumerableSet.UintSet teachers_id_set;

    modifier adminOnly() {
        require(msg.sender == supervisor, "Only admin can call this function");
        _;
    }


    modifier studentOnly() {
        require(students[msg.sender].exist == true, "Only student can call this function");
        _;
    }


    modifier teacherOnly() {
        require(teachers[msg.sender].exist == true, "Only teacher can call this function");
        _;
    }


    constructor() {
        supervisor = msg.sender;

        for (uint i = 0; i < 15; i++) {
            for (uint j = 0; j < 6; j++) {
                for (uint k = 0; k < 7; k++) {
                    scheduleTable[i][j][k] = 0;
                }
            }
        }
    }


    function addSubject(
        uint _id,
        // string memory _name, 
        uint _nClasses,
        uint _day,
        uint _time
    ) public adminOnly {
        require(subjects[_id].exist == false, "There is already such a subject with this id!");
        require(_day <= 5, "day > 5");
        require(_time <= 6, "time > 6");
        require(_nClasses <= 15, "nClasses > number of weeks (15)");
        require(scheduleTable[0][_day][_time] == 0, "This time slot is busy.");
        require(_id != 0, "Subject ID can't equal 0.");
        subjects[_id] = subjectStruct(new Subject(_nClasses), _id, [_day, _time], true);
        EnumerableSet.add(subjects_id_set, _id);
        for (uint i = 0; i < _nClasses; i++) 
        {
            scheduleTable[i][_day][_time] = _id;
        }
    }


    function getScheduleTable(
    ) view public returns(uint[7][6][15] memory) {
        return scheduleTable;
    }

    
    function addStudent(
        // string memory _name, 
        uint _id, 
        address _studentAdr
    ) public adminOnly {
        require(students[_studentAdr].exist == false, 
                 "There is already a student with this address!");
        students[_studentAdr].exist = true;
        // students[_studentAdr].name = _name;
        students[_studentAdr].id = _id;
        EnumerableSet.add(students_set, _studentAdr);
        // EnumerableSet.add(students_id_set, _id);
    }

    
    function addTeacher(
        // string memory _name, 
        uint _id, 
        address _teacherAdr
    ) public adminOnly {
        require(teachers[_teacherAdr].exist == false, 
                 "There is already a student with this address!");
        // teachers[_teacherAdr] = teacherStruct(_name, _id, true);
        teachers[_teacherAdr].exist = true;
        teachers[_teacherAdr].id = _id;
        EnumerableSet.add(teachers_set, _teacherAdr);
        // EnumerableSet.add(teachers_id_set, _id);
    }


    function deleteStudent(
        address _studentAdr
    ) public adminOnly {
        require(students[_studentAdr].exist == true, 
                 "There is no student with this address!");
        // uint _idToDel = students[_studentAdr].id;
        delete students[_studentAdr];
        EnumerableSet.remove(students_set, _studentAdr);
        // EnumerableSet.remove(students_id_set, _idToDel);
    }

    function deleteTeacher(
        address _teacherAdr
    ) public adminOnly {
        require(teachers[_teacherAdr].exist == true, 
                 "There is no teacher with this address!");
        // uint _idToDel = teachers[_teacherAdr].id;
        delete teachers[_teacherAdr];
        EnumerableSet.remove(teachers_set, _teacherAdr);
        // EnumerableSet.remove(teachers_id_set, _idToDel);
    }


    function chooseSubject(
        uint _subjectId
    ) public studentOnly {
        require(subjects[_subjectId].exist == true, "There is no subject with this id!");
        subjects[_subjectId].subject.addStudent(msg.sender);
    }


    function addTeacherToSubject(
        uint _subjectId,
        address _teacherAdr
    ) public adminOnly {
        require(subjects[_subjectId].exist == true, "There is no subject with this id!");
        require(teachers[_teacherAdr].exist == true, 
                "There is no teacher with this address!");
        subjects[_subjectId].subject.addTeacher(_teacherAdr);
        teachers[_teacherAdr].subjects_set.add(_subjectId);
    }

    function approveStudent(
        uint _subjectId,
        address _studentAdr
    ) public teacherOnly {
        require(subjects[_subjectId].exist == true, "There is no subject with this id!");
        require(students[_studentAdr].exist == true, 
                 "There is no student with this address!");
        subjects[_subjectId].subject.approveStudent(_studentAdr);
        students[_studentAdr].subjects_set.add(_subjectId);
    }

    function markStudentToSubject(
        uint _subjectId,
        address _studentAdr,
        uint _day,
        int8 _mark
    ) public teacherOnly {
        require(students[_studentAdr].exist == true, 
                 "There is no student with this address!");
        subjects[_subjectId].subject.markVisit(_studentAdr, _day, _mark);
    }


    function gradeStudentToSubject(
        uint _subjectId,
        address _studentAdr,
        uint _day,
        uint8 _grade
    ) public teacherOnly {
        subjects[_subjectId].subject.giveGrade(_studentAdr, _day, _grade);
    }

    function getScheduleByStudent(
        address _studentAdr,
        uint _weekStart,
        uint _weekEnd
    ) public view returns (uint[7][6][15] memory) {
        require(students[_studentAdr].exist == true, 
                 "There is no student with this address!");
        require(_weekStart < 15, "start week must be < 15");
        require(_weekEnd < 15, "end week must be < 15");
        require(_weekStart <= _weekEnd, "start week must be <= end week");
        uint[7][6][15] memory result; 
        for (uint i = _weekStart ; i <= _weekEnd; i++) {
            for (uint j = 0; j < 6; j++) {
                for (uint k = 0; k < 7; k++) {
                    uint sch_subj = scheduleTable[i][j][k];
                    if (students[_studentAdr].subjects_set.contains(sch_subj)) {
                        result[i][j][k] = sch_subj;
                    }
                }
            }
        }
        return result;
    }


    function getScheduleByTeacher(
        address _teacherAdr,
        uint _weekStart,
        uint _weekEnd
    ) public view returns (uint[7][6][15] memory) {
        require(teachers[_teacherAdr].exist == true, 
                 "There is no teacher with this address!");
        require(_weekStart < 15, "start week must be < 15");
        require(_weekEnd < 15, "end week must be < 15");
        require(_weekStart <= _weekEnd, "start week must be <= end week");
        uint[7][6][15] memory result; 
        for (uint i = _weekStart ; i <= _weekEnd; i++) {
            for (uint j = 0; j < 6; j++) {
                for (uint k = 0; k < 7; k++) {
                    uint sch_subj = scheduleTable[i][j][k];
                    if (students[_teacherAdr].subjects_set.contains(sch_subj)) {
                        result[i][j][k] = sch_subj;
                    }
                }
            }
        }
        return result;
    }


    struct adrGradesStruct {
        address adr;
        int8[] grades;
    }


    function getGradesBySubject(
        uint _subjectId,
        uint _weekStart,
        uint _weekEnd
    ) public view returns (adrGradesStruct[] memory) {
        require(subjects[_subjectId].exist == true, "There is no subject with this id!");
        uint _nClasses = subjects[_subjectId].subject.getNCalsses();
        require(_weekStart < _nClasses, 
                "start week must be < number of classes");
        require(_weekStart <= _weekEnd, "start week must be <= end week");

        address[] memory studentsAddresses = subjects[_subjectId].subject.getApprovedStudents();
        adrGradesStruct[] memory result = new adrGradesStruct[](studentsAddresses.length);
        // adrGradesStruct[] memory result;
        for (uint i = 0; i < studentsAddresses.length; i++) {
            result[i].adr = studentsAddresses[i];
            result[i].grades = subjects[_subjectId].subject.attendanceByStudent(studentsAddresses[i]);
        
        }
        return result;
    }
}