SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[transf_getBrnPODetailsCount] 
	(
		@poh_branch varchar (12)
		, @poh_supplier varchar (8)
		, @poh_refnum varchar (30)
		, @pod_partnumber varchar (20)
		, @pickupdate_from varchar (50)
		, @pickupdate_to varchar (50)
		, @deliverdate_from varchar (50)
		, @deliverdate_to varchar (50)
		, @pd_flag varchar(3)
	)
AS

set nocount on
	--set @poh_branch='226'
	--set @poh_refnum = '0415569200'

	if @poh_supplier is null or ltrim(rtrim(@poh_supplier))=''
		set @poh_supplier = 'UNK'
		
	if @poh_refnum is null or ltrim(rtrim(@poh_refnum))=''
		set @poh_refnum = 'UNK'

	if @pod_partnumber is null or ltrim(rtrim(@pod_partnumber))=''
		set @pod_partnumber = 'UNK'

	declare @poh_pickupdate_from datetime
		, @poh_pickupdate_to datetime
		, @poh_deliverdate_from datetime
		, @poh_deliverdate_to datetime
		
	if @pickupdate_from is null or ltrim(rtrim(@pickupdate_from))=''
		set @poh_pickupdate_from = '1/1/1900 00:00:00'
	else
		set @poh_pickupdate_from = convert(datetime, convert(varchar(12),@pickupdate_from, 101) + ' 00:00:00')

	if @pickupdate_to is null or ltrim(rtrim(@pickupdate_to))=''
		set @poh_pickupdate_to = '12/31/2049 23:59:59'
	else
		set @poh_pickupdate_to = convert(datetime, convert(varchar(12),@pickupdate_to, 101) + ' 23:59:59')

	if @deliverdate_from is null or ltrim(rtrim(@deliverdate_from))=''
		set @poh_deliverdate_from = '1/1/1900 00:00:00'
	else
		set @poh_deliverdate_from = convert(datetime, convert(varchar(12),@deliverdate_from, 101) + ' 00:00:00')
      
	if @deliverdate_to is null or ltrim(rtrim(@deliverdate_to))=''
		set @poh_deliverdate_to = '12/31/2049 23:59:59'
	else
		set @poh_deliverdate_to = convert(datetime, convert(varchar(12),@deliverdate_to, 101) + ' 23:59:59')

	if @pd_flag is null or ltrim(rtrim(@pd_flag)) = ''
		set @pd_flag = 'UNK'

	select 	count(*) as cnt
	from partorder_detail pd
		join partorder_header ph on ph.poh_identity = pd.poh_identity 
			and (ph.poh_supplier = @poh_supplier or @poh_supplier='UNK')
			and (ph.poh_refnum = @poh_refnum or @poh_refnum='UNK')
			and (poh_pickupdate between @poh_pickupdate_from and @poh_pickupdate_to)
			and (poh_deliverdate between @poh_deliverdate_from and @poh_deliverdate_to)
			and ph.poh_branch=@poh_branch
		join partorder_routing pr on ph.poh_identity = pr.poh_identity
		join orderheader oh on oh.ord_hdrnumber = pr.por_ordhdr
		left outer join orderheader om on om.ord_number = oh.ord_fromorder
	where (pd.pod_partnumber = @pod_partnumber or @pod_partnumber='UNK')
		and 
		(
			(case 
			when 1 = (select max(pr1.por_sequence) from partorder_routing pr1 where pr1.poh_identity = ph.poh_identity) then 'PD'
			when por_sequence = 1 then 'PU'
			when por_sequence = (select max(pr1.por_sequence) from partorder_routing pr1 where pr1.poh_identity = ph.poh_identity) then 'DEL'
			when por_sequence is null then 'PD'
			end
			) = @pd_flag
			or
			@pd_flag = 'UNK'
		)


SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[transf_getBrnPODetailsCount] TO [public]
GO
