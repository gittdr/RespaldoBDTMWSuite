SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

--	Modified Date	By	Comment 							
--	-------------	---	-------						
--	5/11/2005		JZ	Created

CREATE PROCEDURE [dbo].[d_adv_profiles_sp] 
	@algh_number int
AS

declare
	@ord_billto varchar(15),
	@ord_revtype1 varchar(15),
	@ord_revtype2 varchar(15),
	@ord_revtype3 varchar(15),
	@ord_revtype4 varchar(15)

--get the fap_type
select @ord_billto=ord_billto, @ord_revtype1=ord_revtype1, @ord_revtype2=ord_revtype2, @ord_revtype3=ord_revtype3, @ord_revtype4=ord_revtype4
	from orderheader
	where ord_hdrnumber in
		(select max (ord_hdrnumber)
			from stops
			where lgh_number = @algh_number)


--get profile by BillTo, RevType1, RevType2, RevType3, RevType4, Default
if exists (select * from cdadvanceprofiles where fap_type='BillTo' and fap_id = @ord_billto)
begin
	select * from cdadvanceprofiles where fap_type='BillTo' and fap_id = @ord_billto
	return
end

if exists (select * from cdadvanceprofiles where fap_type='RevType1' and fap_id = @ord_revtype1)
begin
	select * from cdadvanceprofiles where fap_type='RevType1' and fap_id = @ord_revtype1
	return
end

if exists (select * from cdadvanceprofiles where fap_type='RevType2' and fap_id = @ord_revtype2)
begin
	select * from cdadvanceprofiles where fap_type='RevType2' and fap_id = @ord_revtype2
	return
end

if exists (select * from cdadvanceprofiles where fap_type='RevType3' and fap_id = @ord_revtype3)
begin
	select * from cdadvanceprofiles where fap_type='RevType3' and fap_id = @ord_revtype3
	return
end

if exists (select * from cdadvanceprofiles where fap_type='RevType4' and fap_id = @ord_revtype4)
begin
	select * from cdadvanceprofiles where fap_type='RevType4' and fap_id = @ord_revtype4
	return
end

--default
select * from cdadvanceprofiles where fap_type='Default' and fap_id = 'UNKNOWN'

return

GO
GRANT EXECUTE ON  [dbo].[d_adv_profiles_sp] TO [public]
GO
