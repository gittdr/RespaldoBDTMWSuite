SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[AP_2_payment_raw_data] @pad_batch int, @data varchar(200), @table varchar(30)
as
set nocount on 

/**
 * 
 * NAME:	AP_2_payment_raw_data 
 *
 * TYPE:	[StoredProcedure]
 *
 * DESCRIPTION:
 * This procedure populates the database table with the data that is passed in from @data and @table.  
 * 
 * This proc is called from AP_1_payment_file proc.
 *
 * REVISION HISTORY:
 * JSwindell PTS# 41779	created   7-29-2008
 * JSwindell 8-13-2008 Changed Procs to match Client Raw Data file.
 * PTS 47018 4-29-2009 Client wants to add new column to the transfer.
 * Variable @data declared here needs to match the output from proc 1. So changed @data varchar(75) to 200.
 *
 **/

declare @Pos int, 
		@Length int
select  @Pos = 1, @Length=0

--===============  PARSE the paydetail number =============== 
declare @raw_paydetail_number varchar(30)
declare @numbers_only_paydetail_number varchar(30)

set @raw_paydetail_number = substring(@data, 50, 30)

set @raw_paydetail_number = RTrim(LTrim(@raw_paydetail_number))
set @pos=1
set @Length = LEN(@raw_paydetail_number)
set @numbers_only_paydetail_number=''

If (isnumeric(@raw_paydetail_number)) = 1 
BEGIN
	set @numbers_only_paydetail_number = @raw_paydetail_number
END

If (isnumeric(@raw_paydetail_number)) <> 1 
BEGIN
	while @pos <= @length
	BEGIN
		If (isnumeric(substring(@raw_paydetail_number, @pos,1))) = 1
			Begin	
				set @numbers_only_paydetail_number = @numbers_only_paydetail_number + substring(@raw_paydetail_number, @pos,1)				
			End
		set @pos = @pos + 1
	END

END
-- validate the final number/ if INVALID - set it back to original data for error log reporting.
IF (isnumeric(@numbers_only_paydetail_number) <> 1) OR (@numbers_only_paydetail_number is null) 
BEGIN
	set @numbers_only_paydetail_number =  @raw_paydetail_number
END 
--===============  end of PARSE the paydetail number =============== 

declare @raw_data_date  char(8)
set @raw_data_date = substring(@data, 15, 8)

declare @ap_check_date char(10)
declare @ap_check_number varchar(30)
declare @ap_check_amount decimal(9,2)
declare @ap_vendor_id varchar(30)
declare @ap_voucher_nbr varchar(8)	-- PTS 47018

set @ap_check_number = LTRIM(RTRIM(substring(@data, 23, 10)))
set	@ap_check_date   = substring(@raw_data_date , 5, 2) + '/' + substring(@raw_data_date , 7, 2) + '/' + substring(@raw_data_date , 1, 4)
set @ap_check_amount = substring(@data, 33, 5) + '.' + substring(@data, 38, 2)
set @ap_vendor_id    = LTrim(RTrim(substring(@data, 5, 10))) 
set @ap_voucher_nbr  = LTrim(RTrim(substring(@data, 81, 8)))	-- PTS 47018


insert into AP_payment_data(pad_batch, pad_ap_check_dt, pad_ap_check_nbr, pad_ap_check_amt, pad_ap_vendor_id, pyd_number, pad_ap_voucher_nbr)
select @pad_batch, @ap_check_date ,  @ap_check_number , @ap_check_amount, @ap_vendor_id , @numbers_only_paydetail_number, @ap_voucher_nbr

--===============  end of proc =============== 

-- Original code.  Proc changed due to client raw data file changes.
--declare @col_id int, 
--		@create_sql nvarchar(4000), 
--		@Pos int, 
--		@create_insert nvarchar(4000),
--		@table_id int
--
--if @table is null or @table = '' return
--
--select @table_id = id from sysobjects where name = @table and type = 'U'
--if @table_id is null return	
--
--select @col_id = 2, @Pos = 1
--
--select @create_insert = 'insert '+@table+' (pad_batch,'
--select @create_sql = char(10)+' select '+convert(varchar(25),@pad_batch)+', '
--
--while exists (select * from syscolumns where id = @table_id and colid > @col_id and name like 'pad_%')
--begin
--
--	select @col_id = min(colid) 
--	from syscolumns 
--	where id = @table_id and colid > @col_id and name like 'pad_%'
--
--	select @create_sql = @create_sql + ''''+replace(rtrim(ltrim(substring(@data, @Pos, length))),'''','') + '''', 
--			@Pos= @Pos + length, 
--			@create_insert = @create_insert + name
--	from syscolumns
--	where id = @table_id and colid = @col_id 
--
--	if @col_id  <> (select ( max(colid) - 1)  from syscolumns where id = @table_id)
--		select @create_sql = @create_sql + ',', 
--				@create_insert = @create_insert + ','
--end	
--
--select @create_sql = @create_insert + ')' + @create_sql
--
--exec sp_executesql @create_sql


GO
GRANT EXECUTE ON  [dbo].[AP_2_payment_raw_data] TO [public]
GO
