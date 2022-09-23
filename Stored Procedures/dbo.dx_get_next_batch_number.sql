SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[dx_get_next_batch_number]
	@tpm_id varchar(20)
as

declare @batchnum varchar(45), @batchint int

select @batchnum = tpm_990BatchNumber
  from edi_trading_partner_master
 where tpm_TradingPartnerID = @tpm_id

if isnumeric(@batchnum) = 0
	select @batchnum = '0'

select @batchint = convert(int, @batchnum) + 1
if @batchint > 999999 select @batchint = 1
select @batchnum = convert(varchar, @batchint)
update edi_trading_partner_master
   set tpm_990BatchNumber = @batchnum
 where tpm_TradingPartnerID = @tpm_id

select @batchnum

return

GO
GRANT EXECUTE ON  [dbo].[dx_get_next_batch_number] TO [public]
GO
