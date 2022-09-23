SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create PROC [dbo].[d_load_TPRDB_sp] @tprid varchar(8) , @number int AS

set nocount on
/*
	PTS 52567: 	Proc Created for PTS 52567 - returns a list of ThirdParty ids for 
	the Settlement Tariffs (row/col basis) for (third party difference between) processing.
	The data CAN be filtered on Tpr_type based on a comma delimted (exclude) list from gi_string2 of GI -> ThirdPartyDiffBTW
	(Populates the Thirdparty drop down data list used in d_tar_editrc_tprdb_stl.)
*/

DECLARE @daysout int, @match_rows int, @date datetime
SELECT  @daysout = -90
--vjh 31536
if exists ( SELECT lbp_id FROM ListBoxProperty where lbp_id=@@spid)
select @daysout = lbp_daysout, 
	@date = lbp_date
	from ListBoxProperty
	where lbp_id=@@spid
else
SELECT  @daysout = gi_integer1, 
        @date = gi_date1 
  FROM generalinfo 
 WHERE gi_name = 'GRACE'

if @number = 1 
	set rowcount 1 
else if @number <= 8 
	set rowcount 8
else if @number <= 16
	set rowcount 16
else if @number <= 24
	set rowcount 24
else
	set rowcount 8

if @daysout = 999
	if exists(SELECT tpr_name FROM thirdpartyprofile WHERE tpr_id LIKE @tprid + '%')
		SELECT @match_rows = 1
	else
		SELECT @match_rows = 0
else
	if exists(SELECT tpr_name FROM thirdpartyprofile WHERE tpr_id LIKE @tprid + '%' AND (tpr_active = 'Y' OR tpr_active is null))
		SELECT @match_rows = 1
	else
		SELECT @match_rows = 0

-- Cheaters way to create a temp table
SELECT	top 1 
	   tpr_name, 
       tpr_id, 
       tpr_address1, 
       tpr_address2, 
       tpr_cty_nmstct, 
       tpr_zip, 
       tpr_thirdpartytype1, 
       tpr_thirdpartytype2, 
       tpr_thirdpartytype3, 
       tpr_thirdpartytype4, 
       tpr_thirdpartytype5, 
       tpr_thirdpartytype6,
       tpr_type 
into   #temp_TPRDB
FROM thirdpartyprofile 
where 1 = 1

IF ( Select COUNT(*) from #temp_TPRDB )  > 0 
begin 
	delete from #temp_TPRDB
end 

DECLARE @tpr_types_to_exclude varchar(60)

IF Exists ( select 1 from generalinfo where gi_name like 'ThirdPartyDiffBTW' and UPPER(LTRIM(RTRIM(gi_string1))) = 'ENABLED')
begin
	set @tpr_types_to_exclude = (select LTRIM(RTRIM(gi_string2)) from generalinfo where gi_name like 'ThirdPartyDiffBTW' ) 
	IF LEN (@tpr_types_to_exclude) > 0 
		begin
			set @tpr_types_to_exclude = ',' + @tpr_types_to_exclude + ','
		end 	
end

----------------------------------------
if @match_rows > 0
	if @daysout = 999
		Insert into #temp_TPRDB
		SELECT tpr_name, 
                       tpr_id, 
                       tpr_address1, 
                       tpr_address2, 
                       tpr_cty_nmstct, 
                       ISNULL(tpr_zip, ''), 
                       tpr_thirdpartytype1, 
                       tpr_thirdpartytype2, 
                       tpr_thirdpartytype3, 
                       tpr_thirdpartytype4, 
                       tpr_thirdpartytype5, 
                       tpr_thirdpartytype6,
                       tpr_type                        
                  FROM thirdpartyprofile 
                 WHERE tpr_id LIKE @tprid + '%'
              ORDER BY tpr_id 
	else
		Insert into #temp_TPRDB
		SELECT tpr_name, 
                       tpr_id, 
                       tpr_address1, 
                       tpr_address2, 
                       tpr_cty_nmstct, 
                       ISNULL(tpr_zip, ''), 
                       tpr_thirdpartytype1, 
                       tpr_thirdpartytype2, 
                       tpr_thirdpartytype3, 
                       tpr_thirdpartytype4, 
                       tpr_thirdpartytype5, 
                       tpr_thirdpartytype6,
                       tpr_type 
                  FROM thirdpartyprofile 
                 WHERE tpr_id LIKE @tprid + '%' 
                       AND (tpr_active = 'Y' OR tpr_active is null)
              ORDER BY tpr_id 

else 
	Insert into #temp_TPRDB
	SELECT tpr_name, 
               tpr_id, 
               tpr_address1, 
               tpr_address2, 
               tpr_cty_nmstct, 
               tpr_zip, 
               tpr_thirdpartytype1, 
               tpr_thirdpartytype2, 
               tpr_thirdpartytype3, 
               tpr_thirdpartytype4, 
               tpr_thirdpartytype5, 
               tpr_thirdpartytype6,
               tpr_type 
          FROM thirdpartyprofile 
         WHERE tpr_id = 'UNKNOWN' 


-- filter the data if gi_setting has "exclude" values.
IF LEN (@tpr_types_to_exclude) > 0 
	BEGIN
		delete from  #temp_TPRDB
		where CHARINDEX( ',' + tpr_type + ',' , @tpr_types_to_exclude ) > 0	
	END 

-- final result set
select * from #temp_TPRDB

set rowcount 0 
drop table #temp_TPRDB

GO
GRANT EXECUTE ON  [dbo].[d_load_TPRDB_sp] TO [public]
GO
