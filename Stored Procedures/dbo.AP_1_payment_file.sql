SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE proc [dbo].[AP_1_payment_file] @File varchar(254)
as

set nocount on

/**
 * 
 * NAME:	dbo.AP_1_payment_file
 *
 * TYPE:	[StoredProcedure]
 *
 * DESCRIPTION:
 * This procedure is the Main proc that takes the payment data and updates paydetail table with it.  It calls 2 other procs one for update one for errors.
 *
 *
 *	Usage:  The Users will  need to schedule the daily job to run this proc [AP_1_payment_file] and pass in the IMPORT File Name (txt file).
 *	EXAMPLE:    exec AP_1_payment_file 'c:\rawdata_payment_file.txt'
 *	The incoming txt file needs to have SIX columns:  * there are extra not-named columns - these are ignored by this processing.
 *		pad_ap_check_dt 		date
 *		pad_ap_check_nbr		varchar(30)
 *		pad_ap_check_amt		decimal (7,2)
 *      pad_ap_vendor_id 		varchar(30)	
 *      pad_number				integer		(this must match the paydetail.pyd_number {paydetail key}  ) 
 *      pad_voucher_nbr         varchar(8)   -- PTS 47018
 *
 *
 * REVISION HISTORY:
 * JSwindell PTS# 41779	Created   7-29-2008
 * JSwindell 8-13-2008 Changed Procs to match Client Raw Data file.
 * PTS 47018 4-29-2009 Client wants to add new column to the transfer.  --{ No CODE changes to THIS PROC ! }
 **/

declare @sql nvarchar(1000), 
		@pad_batch int,
		@recordcount int, 
		@successcount int, 
		@failurecount int
select @recordcount = 0, @successcount = 0, @failurecount = 0

create table #rawdata (data char(200))

select @sql = N'BULK INSERT #rawdata FROM ''' + @file + N''' WITH (  DATAFILETYPE = ''char'',   FIELDTERMINATOR = ''|'',  ROWTERMINATOR = ''\n'')'

exec sp_executesql @sql

delete from #rawdata where data is null OR Rtrim(Ltrim(data)) = ''
select @recordcount = count(*) from #rawdata

if @recordcount > 0 
begin
	insert into AP_payment_header(pad_date, pad_filename, pad_recordcount) 
	select getdate(), @file, @recordcount

	select @pad_batch = @@identity
	
	declare @data char(200)
	
	declare payment_data cursor
	read_only
	for select data from #rawdata

	open payment_data
	fetch next from payment_data into @data

	while (@@fetch_status <> -1)
	begin
		if (@@fetch_status <> -2)
			exec AP_2_payment_raw_data @pad_batch, @data, 'AP_payment_data'
		fetch next from payment_data into @data
	end

	close payment_data
	deallocate payment_data

	exec AP_3_payment_update @pad_batch, @successcount OUTPUT, @failurecount OUTPUT
end

drop table #rawdata

update AP_payment_header
set 	pad_recordcount  = @recordcount,
		pad_successcount = @successcount,
		pad_failurecount = @failurecount
where	pad_batch = @pad_batch


GO
GRANT EXECUTE ON  [dbo].[AP_1_payment_file] TO [public]
GO
