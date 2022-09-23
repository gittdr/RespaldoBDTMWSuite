SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[estataco_sp]
 	@login varchar(132)
AS
SET NOCOUNT ON

-- drop temp tables if they already exist
IF OBJECT_ID('tempdb..#estattempbsc') IS NOT NULL 
		DROP TABLE #estattempbsc
IF OBJECT_ID('tempdb..#estattemptt') IS NOT NULL 
		DROP TABLE #estattemptt

--create a temporary table for copying user's existing acolist. 
CREATE TABLE #estattempbsc (temp_billto varchar (8) NULL, temp_shipper varchar (8) NULL, temp_consignee varchar(8) NULL)
CREATE TABLE #estattemptt (tempacoid varchar (8) NULL)

-- copy the existing aco entries for this user
insert into #estattemptt (tempacoid)
select distinct cmp_id from ESTATACOLIST where login = @login
-- Then delete those aco entries from this user's list 
delete from ESTATACOLIST where login = @login

-- make list of the user's estat profile companies
declare @profilecomps table (cmp_id varchar(80) not null )
Insert into @profilecomps select cmp_id from ESTATUSERCOMPANIES where login = @login 

-- now collect aco companies for this user based on companies occurring as bill-to, shipper, etc, 
-- in actual orders on which this user's estat profile companies occur 
insert into #estattempbsc (temp_billto, temp_shipper, temp_consignee)
	select ord_Billto, ord_shipper, ord_consignee 	from orderheader
	where ord_shipper in (select cmp_id from @profilecomps) 
	union
	select ord_Billto, ord_shipper, ord_consignee 	from orderheader
	where ord_company in (select cmp_id from @profilecomps) 
	union
	select ord_Billto, ord_shipper, ord_consignee 	from orderheader
	where ord_consignee in (select cmp_id from @profilecomps) 
	union
	select ord_Billto, ord_shipper, ord_consignee 	from orderheader
	where ord_billto in (select cmp_id from @profilecomps) 

insert into #estattemptt (tempacoid)
	select distinct temp_billto from #estattempbsc

insert into #estattemptt (tempacoid)
	select distinct temp_shipper from #estattempbsc

insert into #estattemptt (tempacoid)
	select distinct temp_consignee from #estattempbsc

if not exists (select * from #estattemptt where tempacoid = 'UNKNOWN')
	insert into #estattemptt select 'UNKNOWN'

-- finally move it all into the actual estataco table, removing duplicates
insert into ESTATACOLIST (login, cmp_id)  
select  distinct @login,  tempacoid from #estattemptt, company
where tempacoid = cmp_id
and cmp_active = 'Y' 
order by tempacoid

-- clean-up temp tables
IF OBJECT_ID('tempdb..#estattempbsc') IS NOT NULL 
		DROP TABLE #estattempbsc
IF OBJECT_ID('tempdb..#estattemptt') IS NOT NULL 
		DROP TABLE #estattemptt

GO
GRANT EXECUTE ON  [dbo].[estataco_sp] TO [public]
GO
