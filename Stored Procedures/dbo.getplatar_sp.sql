SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[getplatar_sp] as
/**
 * 
 * NAME:
 * dbo.getplatar_sp 
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * 
 *
 * RETURNS:
 * 
 * 
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - 
 *       
 * 002 - 
 *
 * REFERENCES: 
 *              
 * Calls001 -   
 * Calls002 -
 *
 * CalledBy001 -
 * CalledBy002 - 
 *
 * REVISION HISTORY:
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names.
 *
 **/

begin
declare @ls_updatesql varchar(255),@ls_insertsql varchar(255),
	@ls_platinumdb varchar(30),@ls_artable varchar(30)
	
select @ls_platinumdb = gi_string1 from generalinfo where gi_name = 'PlatDB'
select @ls_artable = gi_string1 from generalinfo where gi_name = 'PlatArTable'


if  @ls_platinumdb is null or @ls_artable is null
begin
  select 'Platinum DB not set in generalinfo table'
  return -1		
end
	
select @ls_insertsql ='insert into creditcheck(cmp_id,cmp_aging1) Select Isnull(b.cmp_altid,b.cmp_id),'+
			'amt_age_bracket1 '+ 
			'from ' +@ls_platinumdb + '..'+@ls_artable+',company b '+
			'where customer_code=Isnull(b.cmp_altid,b.cmp_id) and '+
			'customer_code not in(Select cmp_id from creditcheck)'

select @ls_insertsql

execute (@ls_insertsql)

select @ls_updatesql = 'Update creditcheck set 	cmp_aging1 = amt_age_bracket1,cmp_aging2 = amt_age_bracket2,'+
	'cmp_aging3 = amt_age_bracket3 from creditcheck ,company b,'+@ls_platinumdb + '..'+@ls_artable+
	' where	customer_code = Isnull(b.cmp_altid,b.cmp_id) and b.cmp_id = creditcheck.cmp_id'

--select @ls_updatesql
EXECUTE (@ls_updatesql)

select @ls_updatesql = 'Update creditcheck set 	cmp_aging4 = amt_age_bracket4,cmp_aging5 = amt_age_bracket5,'+
			'cmp_aging6 = amt_age_bracket6 from creditcheck ,company b,'+@ls_platinumdb + '..'+@ls_artable+
	' where	customer_code = Isnull(b.cmp_altid,b.cmp_id) and b.cmp_id = creditcheck.cmp_id'

--select @ls_updatesql
EXECUTE (@ls_updatesql)


-- JD replaced the following sql with the dynamic sql above
--Update creditcheck set 	cmp_aging1 = amt_age_bracket1,
--			cmp_aging2 = amt_age_bracket2,
--			cmp_aging3 = amt_age_bracket3,
--			cmp_aging4 = amt_age_bracket4, 
--			cmp_aging5 = amt_age_bracket5, 
--			cmp_aging6 = amt_age_bracket6 
--		from  	creditcheck ,company,platdemo..aractcus 
--		where  	customer_code = Isnull(company.cmp_altid,company.cmp_id) and 
--			company.cmp_id = creditcheck.cmp_id

--insert into  creditcheck  Select Isnull(company.cmp_altid,company.cmp_id) ,
--				 amt_age_bracket1,
--				 amt_age_bracket2,
--				 amt_age_bracket3,
--				 amt_age_bracket4, 
--				 amt_age_bracket5, 
--				 amt_age_bracket6 
--			from  	platdemo..aractcus , company 
--			where  	customer_code = Isnull(company.cmp_altid,company.cmp_id) and
--				customer_code not in (Select cmp_id from creditcheck)

end 
GO
GRANT EXECUTE ON  [dbo].[getplatar_sp] TO [public]
GO
