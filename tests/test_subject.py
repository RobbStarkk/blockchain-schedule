import time

import pytest
from brownie import Subject, network, exceptions
from scripts.tools import (
    LOCAL_BLOCKCHAIN_ENVIRONMENTS,
    get_account
)

@pytest.fixture
def deploy_subject_contract():
    subject = Subject.deploy(15, {"from": get_account()})
    assert subject is not None
    return subject


def test_getNCalsses(deploy_subject_contract):
    n_classes = deploy_subject_contract.getNCalsses()
    assert n_classes == 15


def test_addTeacher(deploy_subject_contract):
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("Only for local testing")
    subj_contract = deploy_subject_contract
    subj_contract.addTeacher(get_account(index=1), {"from": get_account()})
    assert subj_contract.hasTeacher(get_account(index=1), {"from": get_account()}) == True


def test_addStudent(deploy_subject_contract):
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("Only for local testing")
    subj_contract = deploy_subject_contract
    subj_contract.addStudent(get_account(index=2), {"from": get_account()})
    assert subj_contract.hasStudent(get_account(index=2), {"from": get_account()}) == True

def test_approveStudent(deploy_subject_contract):
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("Only for local testing")
    subj_contract = deploy_subject_contract
    subj_contract.addStudent(get_account(index=2), {"from": get_account()})
    assert subj_contract.studentIsApproved(get_account(index=2), {"from": get_account()}) == False
    subj_contract.approveStudent(get_account(index=2), {"from": get_account()})
    assert subj_contract.studentIsApproved(get_account(index=2), {"from": get_account()}) == True


def test_grade_system(deploy_subject_contract):
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("Only for local testing")
    subj_contract = deploy_subject_contract
    subj_contract.addTeacher(get_account(index=1), {"from": get_account()})
    subj_contract.addStudent(get_account(index=2), {"from": get_account()})
    subj_contract.approveStudent(get_account(index=2), {"from": get_account()})
    subj_contract.giveGrade(get_account(index=2), 0, 5, {"from": get_account(index=1)})
    assert subj_contract.gradesByStudent(get_account(index=2))[0] == 5


def test_visit_system(deploy_subject_contract):
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("Only for local testing")
    admin_acc = get_account()
    teacher_acc = get_account(index=1)
    student_acc = get_account(index=2)
    subj_contract = deploy_subject_contract
    subj_contract.addTeacher(teacher_acc, {"from": admin_acc})
    subj_contract.addStudent(student_acc, {"from": admin_acc})
    subj_contract.approveStudent(student_acc, {"from": teacher_acc})
    subj_contract.markVisit(student_acc, 0, 1, {"from": teacher_acc}) 
    assert subj_contract.attendanceByStudent(student_acc)[0] == 1


def test_visit_system_err(deploy_subject_contract):
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("Only for local testing")
    admin_acc = get_account()
    teacher_acc = get_account(index=1)
    student_acc = get_account(index=2)
    subj_contract = deploy_subject_contract
    subj_contract.addTeacher(teacher_acc, {"from": admin_acc})
    subj_contract.addStudent(student_acc, {"from": admin_acc})
    subj_contract.approveStudent(student_acc, {"from": teacher_acc})
    with pytest.raises(exceptions.VirtualMachineError):
        subj_contract.markVisit(student_acc, 0, 2, {"from": teacher_acc}) 


def test_delStudent(deploy_subject_contract):
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("Only for local testing")
    admin_acc = get_account()
    teacher_acc = get_account(index=1)
    student_acc = get_account(index=2)
    subj_contract = deploy_subject_contract
    subj_contract.addStudent(student_acc, {"from": admin_acc})
    subj_contract.delStudent(student_acc, {"from": admin_acc})
    assert subj_contract.hasStudent(student_acc, {"from": admin_acc}) == False


def test_disapprove_err(deploy_subject_contract):
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("Only for local testing")
    admin_acc = get_account()
    teacher_acc = get_account(index=1)
    student_acc = get_account(index=2)
    subj_contract = deploy_subject_contract
    subj_contract.addStudent(student_acc, {"from": admin_acc})
    subj_contract.addTeacher(teacher_acc, {"from": admin_acc})
    with pytest.raises(exceptions.VirtualMachineError):
        subj_contract.markVisit(student_acc, 0, 1, {"from": teacher_acc})
    with pytest.raises(exceptions.VirtualMachineError):
        subj_contract.giveGrade(student_acc, 0, 5, {"from": teacher_acc})


def test_grade_err(deploy_subject_contract):
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("Only for local testing")
    admin_acc = get_account()
    teacher_acc = get_account(index=1)
    student_acc = get_account(index=2)
    subj_contract = deploy_subject_contract
    subj_contract.addStudent(student_acc, {"from": admin_acc})
    subj_contract.addTeacher(teacher_acc, {"from": admin_acc})
    subj_contract.approveStudent(student_acc, {"from": teacher_acc})
    with pytest.raises(exceptions.VirtualMachineError):
        subj_contract.giveGrade(student_acc, 0, 6, {"from": teacher_acc})
    with pytest.raises(exceptions.VirtualMachineError):
        subj_contract.giveGrade(student_acc, 0, 0, {"from": teacher_acc})
