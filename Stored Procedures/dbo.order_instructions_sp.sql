SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[order_instructions_sp] @mov int
AS
/**
 * DESCRIPTION:
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
 * 11/30/2007.01 - PTS40464 - JGUO - convert old style outer join syntax to ansi outer join syntax.
 *
 **/
 
BEGIN

--TEMP TABLE FOR RESULTS
create table #t_notes
( 	
temp_id int IDENTITY,
ntb_table char(18),
nre_tablekey char(18),
not_text varchar(4000)
)

-- INTERNAL PARMS
declare @thetable varchar(18)
declare @thekey varchar(18)
declare @bignotestring varchar(4000)
declare @counter int
select @counter = 0
select @bignotestring = ''

--MOVEMENT INSERT 
INSERT INTO  #t_notes
execute d_notes_tripsheet_03_sp 'movement' , @mov
		
--ORDER LOOP
select @thekey = ''
select @thetable = 'orderheader'
while 1=1
BEGIN
		select 	@thekey = min(ord_hdrnumber)
		from	orderheader
		where	mov_number = @mov
				and ord_hdrnumber > @thekey	

		IF @thekey is NULL BREAK

			INSERT INTO  #t_notes
			execute d_notes_tripsheet_03_sp @thetable , @thekey			

END

--TRACTOR LOOP
select @thekey = ''
select @thetable = 'tractorprofile'
while 1=1
BEGIN
		select 	@thekey = min(asgn_id)
		from	assetassignment
		where	mov_number = @mov
				and asgn_type = 'TRC'
				and asgn_id > @thekey
			
		IF @thekey is NULL BREAK

			INSERT INTO  #t_notes
			execute d_notes_tripsheet_03_sp @thetable , @thekey			

END

--TRAILERPROFILE
select @thekey = ''
select @thetable = 'trailerprofile'
while 1=1
BEGIN
		select 	@thekey = min(asgn_id)
		from	assetassignment
		where	mov_number = @mov
				and asgn_type = 'TRL'
				and asgn_id > @thekey
				
		IF @thekey is NULL BREAK

			INSERT INTO  #t_notes
			execute d_notes_tripsheet_03_sp @thetable , @thekey			

END

--MANPOWERPROFILE
select @thekey = ''
select @thetable = 'MANPOWERPROFILE'
while 1=1
BEGIN
		select 	@thekey = min(asgn_id)
		from	assetassignment
		where	mov_number = @mov
				and asgn_type = 'DRV'
				and asgn_id > @thekey
				
		IF @thekey is NULL BREAK

			INSERT INTO  #t_notes
			execute d_notes_tripsheet_03_sp @thetable , @thekey			

END

--COMMODITY
select @thekey = ''
select @thetable = 'COMMODITY'
while 1=1
BEGIN
		select 	@thekey = min(cmd_code)
		from	freightdetail
		where	stp_number in (select stp_number from stops where mov_number = @mov)
			and cmd_code > @thekey
				
		IF @thekey is NULL BREAK
  
			INSERT INTO  #t_notes
			execute d_notes_tripsheet_03_sp @thetable , @thekey			

END


-- STOP COMPANIES
select @thekey = ''
select @thetable = 'company'
while 1=1
BEGIN
		select 	@thekey = min(CMP_ID)
		from	STOPS
		where	mov_number = @mov
				and CMP_ID > @thekey
			
		IF @thekey is NULL BREAK

			INSERT INTO  #t_notes
			execute d_notes_tripsheet_03_sp @thetable , @thekey			

END

select @thekey = ''
select @thetable = 'company'
while 1=1
BEGIN
 		select 	@thekey = min(ord_billto)
		from	ORDERHEADER
 		where	mov_number = @mov
		        and ord_billto > @thekey
 
 				
 		IF @thekey is NULL BREAK

 			INSERT INTO  #t_notes
			execute d_notes_tripsheet_03_sp @thetable , @thekey			

END

--FINAL SELECT
-- 
-- select 	* 
-- from 	#t_notes
-- order by ntb_table

--Populate and return 1 big string

while 1=1
BEGIN
		select 	@counter = min(temp_id)
		from	#t_notes
		where	temp_id > @counter
				
		IF @counter is NULL BREAK

		select @bignotestring = @bignotestring + 'Attached To: '+ rtrim(ltrim(Upper(ntb_table))) + ' Key: ' + ltrim(rtrim(nre_tablekey)) + ' Note: ' + ltrim(rtrim(not_text)) + char(10) + char(13)
		from #t_notes
		where temp_id = @counter

END

create table #temp_text (text_field text)

insert into #temp_text values (@bignotestring)

--select ltrim(rtrim(@bignotestring)) as not_text

--DROP TABLE
drop table #t_notes

select  mpp_firstname + ' '+ CASE mpp_middlename WHEN '' THEN mpp_lastname ELSE mpp_middlename + '. ' + mpp_lastname END AS mpp_fullname,
	--convert(varchar(4000), @bignotestring) 'Order Instructions', 
	#temp_text.text_field,
	c.cmp_name,
	c.cmp_directions,
   cphone.cmp_primaryphone,
	cphone.cmp_secondaryphone,
   orderheader.mov_number,
	orderheader.ord_hdrnumber,
	stp_number,
	legheader.lgh_number

from legheader, manpowerprofile, company c, 
	company cphone RIGHT OUTER JOIN orderheader ON cphone.cmp_id = orderheader.ord_revtype1, 
	stops, #temp_text
where orderheader.mov_number = @mov
  and legheader.mov_number = orderheader.mov_number
  and lgh_driver1 = manpowerprofile.mpp_id
  and c.cmp_id  = stops.cmp_id
  --and cphone.cmp_id =* ord_revtype1
  and stops.ord_hdrnumber = orderheader.ord_hdrnumber
  and legheader.lgh_driver1 = manpowerprofile.mpp_id

END
GO
GRANT EXECUTE ON  [dbo].[order_instructions_sp] TO [public]
GO
