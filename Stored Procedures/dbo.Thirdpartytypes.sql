SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[Thirdpartytypes]
as

/**
 * 
 * NAME:
 * dbo.proc for dw Thirdpartytypes
 *
 * TYPE:
 * [StoredProcedure|
 *
 * DESCRIPTION:
 * proc for d_dddw_thirdpartytypes
 *
 * RETURNS:
 * none
 *
 * RESULT SETS: 
 * dw result set
 *
 * PARAMETERS:
 * none
 * 
 * REVISION HISTORY:
 * 12/09/05 MRH Created
 * 12/28/05 MRH Revised. Removed 'ANY' created UNKNOWN.
 * 07/15/10 PTS 53234 SPN. Changed rsltscode 'UNKNOWN' to UNK 
 *                         to match initial value in the thirdparty profile dw
 *
 **/

create table #results
(
	rsltsname char (20),
	rsltscode char (8)
)

declare @TprType1 char(20)
declare @TprType2 char(20)
declare @TprType3 char(20)
declare @TprType4 char(20)
declare @TprType5 char(20)
declare @TprType6 char(20)

select @TprType1 = (select userlabelname from labelfile where labeldefinition = 'TprType1')
select @TprType2 = (select userlabelname from labelfile where labeldefinition = 'TprType2')
select @TprType3 = (select userlabelname from labelfile where labeldefinition = 'TprType3')
select @TprType4 = (select userlabelname from labelfile where labeldefinition = 'TprType4')
select @TprType5 = (select userlabelname from labelfile where labeldefinition = 'TprType5')
select @TprType6 = (select userlabelname from labelfile where labeldefinition = 'TprType6')

insert into #results (rsltsname, rsltscode) values ('Thirdparty', 'TPR')
insert into #results (rsltsname, rsltscode) values (@TprType1, 'TPR1')
insert into #results (rsltsname, rsltscode) values (@TprType2, 'TPR2')
insert into #results (rsltsname, rsltscode) values (@TprType3, 'TPR3')
insert into #results (rsltsname, rsltscode) values (@TprType4, 'TPR4')
insert into #results (rsltsname, rsltscode) values (@TprType5, 'TPR5')
insert into #results (rsltsname, rsltscode) values (@TprType6, 'TPR6')
--BEGIN PTS 53234 SPN
--insert into #results (rsltsname, rsltscode) values ('UNKNOWN', 'UNKNOWN')
insert into #results (rsltsname, rsltscode) values ('UNKNOWN', 'UNK')
--END PTS 53234 SPN

select rsltsname, rsltscode from #results

drop table #results

GO
GRANT EXECUTE ON  [dbo].[Thirdpartytypes] TO [public]
GO
