import time

import pytest
from brownie import Schedule, network, exceptions
from scripts.tools import (
    LOCAL_BLOCKCHAIN_ENVIRONMENTS,
    get_account
)

@pytest.fixture
def deploy_schedule_contract():
    sch = Schedule.deploy({"from": get_account()})
    assert sch is not None
    return sch


def test_getScheduleTable(deploy_schedule_contract):
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("Only for local testing")
    admin_adr = get_account()
    sch = deploy_schedule_contract
    sch.addSubject(101, 15, 0, 0, {"from": admin_adr})
    assert sch.getScheduleTable()[0][0][0] == 101


def test_chooseSubject(deploy_schedule_contract):
    admin_adr = get_account()
    teacher_adr = get_account(index=1)
    student_adr = get_account(index=2)
    sch = deploy_schedule_contract
    sch.addSubject(101, 15, 0, 0, {"from": admin_adr})
    sch.addTeacher(1, teacher_adr, {"from": admin_adr})
    sch.addStudent(2, student_adr, {"from": admin_adr})
    sch.chooseSubject(101, {"from": student_adr})
    sch.addTeacherToSubject(101, teacher_adr, {"from": admin_adr})
    sch.approveStudent(101, student_adr, {"from": teacher_adr})
    assert sch.getScheduleByStudent(student_adr, 0, 2)[0][0][0] == 101


def test_approve_err(deploy_schedule_contract):
    admin_adr = get_account()
    teacher_adr = get_account(index=1)
    student_adr = get_account(index=2)
    sch = deploy_schedule_contract
    sch.addSubject(101, 15, 0, 0, {"from": admin_adr})
    sch.addTeacher(1, teacher_adr, {"from": admin_adr})
    sch.addStudent(2, student_adr, {"from": admin_adr})
    sch.chooseSubject(101, {"from": student_adr})
    sch.addTeacherToSubject(101, teacher_adr, {"from": admin_adr})
    with pytest.raises(AssertionError):
        assert sch.getScheduleByStudent(student_adr, 0, 2)[0][0][0] == 101
    with pytest.raises(exceptions.VirtualMachineError):
        sch.gradeStudentToSubject(101, student_adr, 0, 1)
    with pytest.raises(exceptions.VirtualMachineError):
        sch.gradeStudentToSubject(101, student_adr, 0, 1)
    with pytest.raises(exceptions.VirtualMachineError):
        sch.markStudentToSubject(101, student_adr, 0, 1)


def test_addSubject(deploy_schedule_contract):
    admin_adr = get_account()
    teacher_adr = get_account(index=1)
    sch = deploy_schedule_contract
    sch.addSubject(101, 15, 0, 0, {"from": admin_adr})
    assert sch.getScheduleTable()[0][0][0] == 101
    with pytest.raises(exceptions.VirtualMachineError):
        sch.addSubject(101, 15, 0, 0, {"from": admin_adr})
    with pytest.raises(exceptions.VirtualMachineError):
        sch.addSubject(102, 15, 0, 0, {"from": admin_adr})
    with pytest.raises(exceptions.VirtualMachineError):
        sch.addSubject(102, 15, 6, 0, {"from": admin_adr})
    with pytest.raises(exceptions.VirtualMachineError):
        sch.addSubject(102, 15, 0, 7, {"from": admin_adr})
    with pytest.raises(exceptions.VirtualMachineError):
        sch.addSubject(102, 16, 1, 1, {"from": admin_adr})
    with pytest.raises(exceptions.VirtualMachineError):
        sch.addSubject(0, 15, 1, 1, {"from": admin_adr})
    with pytest.raises(exceptions.VirtualMachineError):
        sch.addSubject(102, 15, 1, 1, {"from": teacher_adr})
