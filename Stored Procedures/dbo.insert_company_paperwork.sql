SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[insert_company_paperwork] (@cmp_id varchar(8))
AS 

DECLARE @defaultCompanyPaperwork char(1), 
        @billto   char(1),
        @required char(1),
		@max_seq int  --PTS 38909

-- check general info setting, if not set the exit
select @defaultCompanyPaperwork = isnull(substring(gi_string1, 1, 1), 'N'), 
       @required = upper(isnull(substring(gi_string2, 1, 1), 'N'))
  from generalinfo 
 where gi_name = 'DefaultCompanyPaperwork'
if @defaultCompanyPaperwork = 'N'
	return

-- check if company is marked a billto, if not then exit
select @billto = isnull(cmp_billto, 'N') 
  from company 
 where cmp_id = @cmp_id 
if @billto = 'N'
	return

--PTS 38909 EMK - Need Sequence to be 1...N, not paperwork code.

--Get the current maximum sequence number
select @max_seq = IsNull(max(bdt_sequence),0) from billdoctypes where cmp_id = @cmp_id

--Note that the two columns bdt_required, bdt_attach will be NULL, which defaults to required in the system
--Identity function doesn't allow variables in seed i.e. cant use identity(int,@var,1)
select @cmp_id as cmp_id, abbr, identity(int,1,1) as temp_ident, 0 as temp_seq into #temp_billdoc  
       from labelfile 
      where labeldefinition = 'PaperWork' 
        and isnull(retired, 'N') = 'N' 
        and abbr not in (select distinct bdt_doctype 
                           from BillDoctypes 
                          where cmp_id = @cmp_id)
        and ((upper(ltrim(rtrim(label_extrastring1))) = 'REQUIRED' and @required = 'Y') or @required <> 'Y')


--Add the max sequence. 
update #temp_billdoc set temp_seq = temp_ident+@max_seq

insert into BillDoctypes (cmp_id, bdt_doctype, bdt_sequence)
select cmp_id,abbr,temp_seq
from #temp_billdoc

drop table #temp_billdoc
/*
-- insert and entry for each non-retired paperwork setting
insert into BillDoctypes (cmp_id, bdt_doctype, bdt_sequence)
	 select @cmp_id, abbr, code 
       from labelfile 
      where labeldefinition = 'PaperWork' 
        and isnull(retired, 'N') = 'N' 
        and abbr not in (select distinct bdt_doctype 
                           from BillDoctypes 
                          where cmp_id = @cmp_id)
        and ((upper(ltrim(rtrim(label_extrastring1))) = 'REQUIRED' and @required = 'Y') or @required <> 'Y')
*/

--PTS 38909 EMK
GO
GRANT EXECUTE ON  [dbo].[insert_company_paperwork] TO [public]
GO
