SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


create proc [dbo].[insertwebrecruit_sp](
@p_rec_firstname varchar(40),
@p_rec_middlename varchar(1),
@p_rec_lastname varchar(40),
@p_rec_address1 varchar(30),
@p_rec_address2 varchar(30),
@p_rec_city int,
@p_rec_enteredcity varchar(45),
@p_rec_county varchar(40),
@p_rec_state varchar(6),
@p_rec_zip varchar(10),
@p_rec_homephone varchar(20),
@p_rec_cellphone varchar(20),
@p_rec_fax varchar(20),
@p_rec_email varchar(50),
@p_rec_website varchar(50),
@p_rec_referral varchar(50),
@p_rec_division varchar(50),
@p_rec_reasoncall varchar(50),
@p_rec_type1 varchar(50),
@p_rec_type2 varchar(50),
@p_rec_type3 varchar(50),
@p_rec_type4 varchar(50),
@p_rec_type5 varchar(50),
@p_rec_type6 varchar(50),
@p_rec_type7 varchar(50),
@p_rec_type8 varchar(50),
@p_rec_type9 varchar(50),
@p_rec_type10 varchar(50),
@p_trc_type1 varchar(6),
@p_trc_type2 varchar(6),
@p_trc_type3 varchar(6),
@p_trc_type4 varchar(6),
@p_rec_cdlendoursements varchar(500))
as
/***************************************************


exec dbo.InsertWebRecruit_sp 'Troy', 'Q', 'Smith', '123 main st','',  'cleveland', 'oh', '44444',
	'555 123-4567', '555 111-2222', '555 333-4444', 'joe@abc', 'www.abc.com', 'ref', 'div','reason',
'(Haz-mat Training, Goggles, Team Requested, Steel Toed Boots)'


***************************************************/
set nocount ON

declare @v_cols nvarchar(2000),
	@v_vals nvarchar(2000),
	@v_rec_id int,
	@v_s_rec_id varchar(10),
	@v_cdlinsert nvarchar(1000)


set @v_cols = 'Insert into RecruitHeader('
set @v_vals = 'Values('
if len(@p_rec_firstname) > 0 
begin
	set @v_cols = @v_cols + 'rec_firstname, '
	set @v_vals = @v_vals + '''' + @p_rec_firstname + ''', '
end

if len(@p_rec_middlename) > 0 
begin
	set @v_cols = @v_cols + 'rec_middlename, '
	set @v_vals = @v_vals + '''' + @p_rec_middlename + ''', '
end

if len(@p_rec_lastname) > 0 
begin
	set @v_cols = @v_cols + 'rec_lastname, '
	set @v_vals = @v_vals + '''' + @p_rec_lastname + ''', '
end

if len(@p_rec_address1) > 0 
begin
	set @v_cols = @v_cols + 'rec_address1, '
	set @v_vals = @v_vals + '''' + @p_rec_address1 + ''', '
end

if len(@p_rec_address2) > 0 
begin
	set @v_cols = @v_cols + 'rec_address2, '
	set @v_vals = @v_vals + '''' + @p_rec_address2 + ''', '
end

if len(@p_rec_city) > 0 
begin
	set @v_cols = @v_cols + 'rec_city, '
	set @v_vals = @v_vals + '''' + cast(@p_rec_city as varchar(20)) + ''', '
end

if len(@p_rec_enteredcity) > 0 
begin
	set @v_cols = @v_cols + 'rec_enteredcity, '
	set @v_vals = @v_vals + '''' + @p_rec_enteredcity + ''', '
end

if len(@p_rec_county) > 0 
begin
	set @v_cols = @v_cols + 'rec_county, '
	set @v_vals = @v_vals + '''' + @p_rec_county + ''', '
end

if len(@p_rec_state) > 0 
begin
	set @v_cols = @v_cols + 'rec_state, '
	set @v_vals = @v_vals + '''' + @p_rec_state + ''', '
end

if len(@p_rec_zip) > 0 
begin
	set @v_cols = @v_cols + 'rec_zip, '
	set @v_vals = @v_vals + '''' + @p_rec_zip + ''', '
end

if len(@p_rec_homephone) > 0 
begin
	set @v_cols = @v_cols + 'rec_homephone, '
	set @v_vals = @v_vals + '''' + @p_rec_homephone + ''', '
end

if len(@p_rec_cellphone) > 0 
begin
	set @v_cols = @v_cols + 'rec_cellphone, '
	set @v_vals = @v_vals + '''' + @p_rec_cellphone + ''', '
end

if len(@p_rec_fax) > 0 
begin
	set @v_cols = @v_cols + 'rec_fax, '
	set @v_vals = @v_vals + '''' + @p_rec_fax + ''', '
end

if len(@p_rec_email) > 0 
begin
	set @v_cols = @v_cols + 'rec_email, '
	set @v_vals = @v_vals + '''' + @p_rec_email + ''', '
end

if len(@p_rec_website) > 0 
begin
	set @v_cols = @v_cols + 'rec_website, '
	set @v_vals = @v_vals + '''' + @p_rec_website + ''', '
end

if len(@p_rec_referral) > 0 
begin
	set @v_cols = @v_cols + 'rec_referral, '
	set @v_vals = @v_vals + '''' + @p_rec_referral + ''', '
end

if len(@p_rec_division) > 0 
begin
	set @v_cols = @v_cols + 'rec_division, '
	set @v_vals = @v_vals + '''' + @p_rec_division + ''', '
end

if len(@p_rec_reasoncall) > 0 
begin
	set @v_cols = @v_cols + 'rec_reasoncall, '
	set @v_vals = @v_vals + '''' + @p_rec_reasoncall + ''', '
end

if len(@p_rec_type1) > 0 
begin
	set @v_cols = @v_cols + 'rec_type1, '
	set @v_vals = @v_vals + '''' + @p_rec_type1 + ''', '
end

if len(@p_rec_type2) > 0 
begin
	set @v_cols = @v_cols + 'rec_type2, '
	set @v_vals = @v_vals + '''' + @p_rec_type2 + ''', '
end

if len(@p_rec_type3) > 0 
begin
	set @v_cols = @v_cols + 'rec_type3, '
	set @v_vals = @v_vals + '''' + @p_rec_type3 + ''', '
end

if len(@p_rec_type4) > 0 
begin
	set @v_cols = @v_cols + 'rec_type4, '
	set @v_vals = @v_vals + '''' + @p_rec_type4 + ''', '
end

if len(@p_rec_type5) > 0 
begin
	set @v_cols = @v_cols + 'rec_type5, '
	set @v_vals = @v_vals + '''' + @p_rec_type5 + ''', '
end

if len(@p_rec_type6) > 0 
begin
	set @v_cols = @v_cols + 'rec_type6, '
	set @v_vals = @v_vals + '''' + @p_rec_type6 + ''', '
end

if len(@p_rec_type7) > 0 
begin
	set @v_cols = @v_cols + 'rec_type7, '
	set @v_vals = @v_vals + '''' + @p_rec_type7 + ''', '
end

if len(@p_rec_type8) > 0 
begin
	set @v_cols = @v_cols + 'rec_type8, '
	set @v_vals = @v_vals + '''' + @p_rec_type8 + ''', '
end

if len(@p_rec_type9) > 0 
begin
	set @v_cols = @v_cols + 'rec_type9, '
	set @v_vals = @v_vals + '''' + @p_rec_type9 + ''', '
end

if len(@p_rec_type10) > 0 
begin
	set @v_cols = @v_cols + 'rec_type10, '
	set @v_vals = @v_vals + '''' + @p_rec_type10 + ''', '
end

if len(@p_trc_type1) > 0 
begin
	set @v_cols = @v_cols + 'trc_type1, '
	set @v_vals = @v_vals + '''' + @p_trc_type1 + ''', '
end

if len(@p_trc_type2) > 0 
begin
	set @v_cols = @v_cols + 'trc_type2, '
	set @v_vals = @v_vals + '''' + @p_trc_type2 + ''', '
end

if len(@p_trc_type3) > 0 
begin
	set @v_cols = @v_cols + 'trc_type3, '
	set @v_vals = @v_vals + '''' + @p_trc_type3 + ''', '
end

if len(@p_trc_type4) > 0 
begin
	set @v_cols = @v_cols + 'trc_type4, '
	set @v_vals = @v_vals + '''' + @p_trc_type4 + ''', '
end


set @v_cols = @v_cols + 'rec_createdon, '
set @v_vals = @v_vals + '''' + cast(getdate() as varchar(30)) + ''', '


set @v_cols = @v_cols + 'rec_createdby, '
set @v_vals = @v_vals + '''Web'', '


set @v_cols = substring( @v_cols , 1 , len(@v_cols) -1 )+ ')' 
set @v_vals = substring( @v_vals , 1 , len(@v_vals) -1 )+ ')' 

set @v_cols = @v_cols + ' ' + @v_vals


exec sp_executesql @v_cols

select @v_rec_id = @@identity
set @v_s_rec_id = cast(@v_rec_id as varchar(10))


if len(@p_rec_cdlendoursements) > 0
begin
	set @v_cdlinsert = 'insert into recruitqualifications(
	rec_id, rcq_type)
	select ' + cast(@v_rec_id as varchar(9)) + ', abbr from labelfile
	where labeldefinition = ''DrvAcc'' and name in ' + @p_rec_CDLEndoursements

	exec sp_executesql @v_cdlinsert
end

insert recruitcorrespondence(rec_id, rcr_datesent, rcr_docname, rcr_method)
values (@v_rec_id, getdate(), 'New', 'New Entry')

set nocount OFF

GO
GRANT EXECUTE ON  [dbo].[insertwebrecruit_sp] TO [public]
GO
