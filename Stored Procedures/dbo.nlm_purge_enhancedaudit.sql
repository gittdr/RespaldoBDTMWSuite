SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[nlm_purge_enhancedaudit] (
		@keepdays int, 
		@include_standard_audit char(1)= 'N')
AS
CREATE TABLE #nlm_numbers (nlm_shipment_number int)

select @keepdays = abs(@keepdays) * -1

--get the shipment numbers that we want to deal with useing the inital download time
insert into #nlm_numbers
select nlm_shipment_number
  from nlmaudit
 where nlma_updated_dt < dateadd(dd,@keepdays,getdate())
   and nlma_code = 10

--Some users may want to keep the standard logging
if @include_standard_audit = 'Y'
	delete from nlmaudit where nlm_shipment_number in (select nlm_shipment_number from #nlm_numbers)

-- remove the records from all the staging tables
delete from nlmbid where nlm_shipment_number in (select nlm_shipment_number from #nlm_numbers)
delete from nlmlocations where nlm_shipment_number in (select nlm_shipment_number from #nlm_numbers)
delete from nlmpieces where nlm_shipment_number in (select nlm_shipment_number from #nlm_numbers)
delete from nlmshipment where nlm_shipment_number in (select nlm_shipment_number from #nlm_numbers)
delete from can_loads where nlm_shipment_number in (select nlm_shipment_number from #nlm_numbers)
delete from nlmshipmentupdate_history where nlm_shipment_number in (select nlm_shipment_number from #nlm_numbers)

GO
GRANT EXECUTE ON  [dbo].[nlm_purge_enhancedaudit] TO [public]
GO
