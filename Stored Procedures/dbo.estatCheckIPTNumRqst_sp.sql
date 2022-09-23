SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[estatCheckIPTNumRqst_sp] 
	@company varchar(16),  	-- estat profile primary company id
 	@func varchar(6), 		-- function to be performed
	@number int
-- This proc is used by the estat Request Empty Trailers to check
-- and manage the number of empty trailer requests submitted by a user. 
-- Note that this proc does not prevent the current count from exceding the max.
-- But it does set the allowed amount to zero if current is >= the max.
-- Definition: an empty trailer request is any order whose commodity on the first
-- stop is XX. (Initially the shipper will be MTRQST, but this can change.)

---- estatCheckIPTNumRqst_sp   '04', 'info', 0    -- just return info for company 04
---- estatCheckIPTNumRqst_sp   '04', 'setmax', 8 -- reset the max allowed to 8, for company 04   
---- estatCheckIPTNumRqst_sp   'ALLCOMPANIES', 'setmax', 3 -- reset the max allowed to 8 for all companies   

as 
SET NOCOUNT ON

if @number < 0 select @number = 0
--@max: the maximum number of trailer requests allowed for this company at any one time
declare @max as int 
declare @allowed as int
declare @current as int 


-- if not the special case then perform functions for the specific company
if @company <> 'ALLCOMPANIES' 
begin 
	select @max = isnull(reqmax,0) from   estatIPLTETTREQCount where reqcmp_id = @company 
	-- If there is no entry for this company create one.
	if not exists (select 1 from estatIPLTETTREQCount where reqcmp_id = @company )
		begin
		insert into estatIPLTETTREQCount 
		(reqcmp_id, reqcurrent, reqmax)
		values(@company,0,@max ) 
	end

	-- Calculate and store the current number of empty requests for this company 
	CREATE TABLE #requests (ord_hdrnumber int NULL, cmdcode varchar(8) NULL)
	insert into #requests (ord_hdrnumber)
	select distinct ord_hdrnumber from orderheader
	where 	(ord_company = @company 
		and ord_status in ('AVL', 'PLN', 'DSP', 'STD')
		and ord_shipper = 'MTRQST' ) 
	update #requests set cmdcode = cmd_code from stops
	where #requests.ord_hdrnumber = stops.ord_hdrnumber
		and stops.stp_mfh_sequence = 1
	delete #requests where cmdcode <> 'XX'

	-- #requests now holds shipments that are strictly empty trailer requests

	update estatIPLTETTREQCount 
	set reqcurrent = (select count(*) from #requests )  --12/29/08
	where reqcmp_id = @company -- ) -- 12/29/08
	drop table #requests
	-- Get the current number of requests
	select @current = isnull(reqcurrent,0) from  estatIPLTETTREQCount where reqcmp_id = @company 
	-- Calculate the allowed
	select @allowed = @max - @current 
	if @allowed < 0  select @allowed = 0


	if @func = 'info' 
		begin 
		  select @max max, @current [current], @allowed allowed
		end
	else if @func = 'setmax'
		begin
			update estatIPLTETTREQCount set reqmax = @number where reqcmp_id = @company 	
		end  
end
else -- special case: all companies 
if @func = 'setmax'
		begin
           -- 12/29/08: Refresh the contents of estatIPLTETTREQCount, supplying the new max value and 
            -- possible new companies from the company table while preserving any existing current request values
			CREATE TABLE #temp (reqcmp_id varchar(8) NULL, reqcurrent int NULL, reqmax int NULL)

			insert into #temp
				select a.cmp_id as reqcmp_id, isnull(reqcurrent,0), @number as reqmax from company a 
				left join estatIPLTETTREQCount b on b.reqcmp_id = a.cmp_id
				where cmp_id <> 'UNKNOWN' 
				delete from estatIPLTETTREQCount
				insert into estatIPLTETTREQCount SELECt * from #temp
				drop table #temp
/* 12/29/08:

            delete from estatIPLTETTREQCount -- remove all entries so we can insert  
            insert into estatIPLTETTREQCount (reqcmp_id) 
				select cmp_id from company where cmp_id <> 'UNKNOWN' 
			update estatIPLTETTREQCount set reqmax = @number
			update estatIPLTETTREQCount set reqcurrent = 0 	12/29/08
*/
		end  

GO
GRANT EXECUTE ON  [dbo].[estatCheckIPTNumRqst_sp] TO [public]
GO
