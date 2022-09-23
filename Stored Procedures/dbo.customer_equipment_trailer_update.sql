SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[customer_equipment_trailer_update]	
					@lgh_number				int,
				  	@trl_id					varchar(13), 
					@sp_update				char(1)	OUT,
					@sp_validation_message	varchar(1000) OUT
					
AS
/*  Paramater explination
lgh_number               -   leg that is to be updated
trl_id                   -   trailer number entered on TM Form
sp_update                -   flag indicating if the stored procedure will handle the update 
                             or if totalmail will handle the trailer update as a normal update
                             possible return values Y/N
sp_validation_message    -   if the stored procedure is handling the update there will be a status
							 message here, if the value is not 'Update Successful' then the form should
							 error out and display this message as the error
*/
declare @lgh_count int, @overlap_leg int, @valid_count int
declare @valid_prefix varchar(2000), @orig_prefix varchar(2000)
declare @pos int, @currentLocation char(2000)
declare @temp_table table (value varchar(2000))
select @lgh_count = COUNT(1)
  from legheader lgh
  join trailerprofile trl on lgh.lgh_primary_trailer = trl.trl_id
 where lgh_number = @lgh_number
   and trl.trl_id <> 'UNKNOWN'
   and trl.trl_validitychks = 'N'

--This is a normal trailer update return back out so TM can process 
if @lgh_count < 1
begin
	select @sp_update = 'N'
	select @sp_validation_message = 'Normal Trailer Processing'
	return
end
else
	select @sp_update = 'Y'
--Perform validation / set any error information return if there is an error

--prefix validation

 select @pos=0
 select @valid_prefix = isnull(ltrim(rtrim(c.cmp_custequipprefix)),'')
  from legheader l 
  join orderheader o on o.ord_hdrnumber = l.ord_hdrnumber
  join company c on c.cmp_id = o.ord_billto
 where l.lgh_number = @lgh_number
 select @orig_prefix = @valid_prefix
 SELECT @valid_prefix = ',' + @valid_prefix + ','
 
while CHARINDEX(',',@valid_prefix) > 0
begin
 select @pos=CHARINDEX(',',@valid_prefix)
 select @currentLocation = RTRIM(SUBSTRING(@valid_prefix,1,@pos-1))
 if ltrim(rtrim(len(@currentlocation))) > 0
	insert into @temp_table values (@currentLocation)
	select @valid_prefix=SUBSTRING(@valid_prefix,@pos+1,2000)
end

select @valid_count = count(*) 
  from @temp_table
 where value <> ''
   and value = substring(@trl_id,1,len(value))
if @valid_count < 1
begin
	select @sp_validation_message = 'The Trailer ID entered (' + @trl_id + ') must begin with a '''+ @orig_prefix + ''' prefix.'
	return
end

--no overlap validation
select @overlap_leg = min(derived_table.lgh_number) 
  from (select l.lgh_number, lgh_startdate, lgh_enddate 
          from customerequipment c 
          join legheader l on c.lgh_number = l.lgh_number and c.ce_equipnum = @trl_id
         where c.lgh_number <> @lgh_number) as derived_table 
  join legheader lgh on lgh.lgh_number = @lgh_number 
 where (lgh.lgh_startdate < derived_table.lgh_enddate 
   and lgh.lgh_enddate > derived_table.lgh_startdate) 
    OR (derived_table.lgh_startdate < lgh.lgh_enddate 
        and derived_table.lgh_enddate > lgh.lgh_startdate) 
    OR (lgh.lgh_startdate > derived_table.lgh_startdate 
        and lgh.lgh_enddate < derived_table.lgh_enddate)
    OR (derived_table.lgh_startdate > lgh.lgh_startdate and derived_table.lgh_enddate < lgh.lgh_enddate)
if @overlap_leg > 0
begin
	select @sp_validation_message = 'The Trailer ID entered (' + @trl_id + ') is already in use on leg ' + CONVERT(varchar(100), @lgh_number) + '.'
	return
end 
--validation is good check if record exists already if not create
if not exists (select *
                 from CustomerEquipment
                where lgh_number = @lgh_number
                  and ce_equipnum = @trl_id)
begin
insert into CustomerEquipment(lgh_number, ce_seqnum, ce_equipnum)
select lgh_number, MAX(isnull(ce_seqnum,0)), @trl_id
  from CustomerEquipment
 where lgh_number = @lgh_number
  group by lgh_number
end

select @sp_validation_message = 'Update Successful'
GO
GRANT EXECUTE ON  [dbo].[customer_equipment_trailer_update] TO [public]
GO
