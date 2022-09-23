SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[CandidateProducts_sp] @cmpid Varchar(8),@Cmd varchar(8),
   @Date datetime , @PUPorDRP varchar(6),@fgtnbr int
	
AS
/**
 * DESCRIPTION:
	Pass a company and a commodity and an indication if this is a pickup or a drop and the date of
    pickup or delivery and it will return all the candidates from the company products table.  Will be callled
    recursively by the spplication for each company/coomodity/date combination for pickup and placed
    in an appended datastore.  The same for delivery (into another datastore) then matched.

    On pickup, if the commodity is UNKNOWN, select all commodities which match on date since TMW does not
    require one to specify what was picked up.
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
 * 4/14/4 Created DPETE
 * 11/28/2007.01 ? PTS40462 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 * 12/16/12 PTS66204 set fgt_supplier from products that can be shipped
 *
 **/
Declare @DateMonth tinyint,@DateDay tinyint
Select @DateMonth = Datepart(month,@date),@DateDay=Datepart(day,@Date)


/* Candidate products for pickup */
Select cmp_id = cpr.cmp_id 
,cmd_code = cpr.cmd_code
,scm_subcode = IsNull(cpr.scm_subcode,'')
,product = cpr.cmd_code+IsNull(cpr.scm_subcode,'')
,cpr_density = IsNull(cpr_density ,1)
,fgt_number = @fgtnbr
,goodproduct = 'Y'  -- flag modifed by validate code in app
,scm_description = IsNull(subcommodity.scm_description,'')
,isnull(fgt_supplier,'UNKNOWN') fgt_supplier
--pts40462 outer join conversion
From subcommodity  RIGHT OUTER JOIN  companyproduct cpr  ON  (subcommodity.cmd_code  = cpr.cmd_code  AND Subcommodity.scm_subcode  = cpr.scm_subcode ) 
where  cpr_pup_or_drp = @PUPorDRP
And cmp_id = @cmpid
And @cmd in (cpr.cmd_code ,Case @PUPorDRP When 'PUP' Then 'UNKNOWN'Else NULL End)
-- limit to those companyproducts records whos date range include the  date passed
and 1 = 
Case 
-- example 2/10 to 10/15
      When cpr_startmonth < cpr_endMonth
        and @DateMonth > cpr_startmonth
        and @DateMonth < cpr_endmonth
      Then 1
      When cpr_startmonth < cpr_endmonth
        and @DateMonth = cpr_startmonth
        and @DateDay >= cpr_startday
      Then 1
      When cpr_Startmonth < cpr_endMonth
        and @DateMonth = cpr_endmonth
        and @DateDay <= cpr_endday
      Then 1 
-- example from, 2/5 to 2/25
      When cpr_startmonth = cpr_endMonth and cpr_startday <= cpr_endday
        and @DateMonth = cpr_StartMonth
        And @DateDay >= cpr_startday
        And @DateDay <= cpr_endday
      Then 1
-- example from 10/1 to 2/10
      When cpr_startmonth > cpr_endmonth 
       and (@DateMonth > cpr_startmonth
       OR   @DateMonth < cpr_endmonth)
      Then 1
      When cpr_startmonth > cpr_endmonth
       and @DateMonth = cpr_startmonth
       and @DateDay >= cpr_startday
      Then 1
      When cpr_startmonth > cpr_endmonth
       and @DateMonth = cpr_endmonth
       and @DateDay <= cpr_endday
      Then 1
-- example From 2/25 to 2/1
       When cpr_startmonth = cpr_endMonth and cpr_startday > cpr_endday
       and @DateMonth > cpr_endmonth
       Then 1
       When cpr_startmonth = cpr_endMonth and cpr_startday > cpr_endday
       and @DateMonth < cpr_endmonth
       Then 1
       When cpr_startmonth = cpr_endMonth and cpr_startday > cpr_endday
       and @DateMonth =  cpr_startmonth
       and (@DateDay >= cpr_startday
        OR   @DateDay <= cpr_endday)
       Then 1
       
      Else  0
      end
--And subcommodity.cmd_code =* cpr.cmd_code
--And Subcommodity.scm_subcode =* cpr.scm_subcode
Order By cpr.cmp_id,cpr.cmd_code,IsNull(cpr.scm_subcode,'')

GO
GRANT EXECUTE ON  [dbo].[CandidateProducts_sp] TO [public]
GO
