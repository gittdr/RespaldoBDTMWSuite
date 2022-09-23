SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
Create proc [dbo].[d_partorder_massTLM_routes] (@poh_identities varchar(255))
as
/**
 * 
 * NAME:
 * d_partorder_massTLM_routes
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 *
 * RETURNS:
 * dw result set
 *
 * PARAMETERS:
 * 001 - @poh_identity int - partorder id
 * 
 * REVISION HISTORY:
 *
 **/

declare @poh_identity integer
declare @comma integer
declare @firstcomma integer
declare @sequence integer
declare @stop_count integer
declare @old_sequence integer

declare @working table(
	por_origin varchar(8),
	por_destination varchar(8),
	por_sequence integer,
	poh_identity integer
	)
declare @results table(
	por_origin varchar(8),
	por_destination varchar(8),
	por_sequence integer
	)

if (select CHARINDEX (',', @poh_identities, 1)) > 0
begin
	select @firstcomma = 1
	select @comma = 1
	while @comma <= len(@poh_identities)
	begin
		select @comma = CHARINDEX (',', @poh_identities, @comma)
		if @comma = 0
			select @comma = len(@poh_identities) + 1
		select @poh_identity = convert(integer, substring(@poh_identities, @firstcomma, @comma - @firstcomma))
		insert into @working (por_origin, por_destination, por_sequence, poh_identity) select por_origin, por_destination, por_sequence, poh_identity from partorder_routing where poh_identity = @poh_identity order by por_sequence
		select @comma = @comma + 1
		select @firstcomma = @comma
	end
end
else
begin
	select @poh_identity = convert(integer, @poh_identities)
	insert into @working (por_origin, por_destination, por_sequence) select por_origin, por_destination, por_sequence from partorder_routing where poh_identity = @poh_identity order by por_sequence
end

--Reset the sequence to be ordered from the drop backwards.
select @sequence = max(por_sequence) from @working
while @sequence is not null
begin
	select @poh_identity = max(poh_identity) from @working
	while @poh_identity is not null
	begin
		select @old_sequence = max(por_sequence) from @working where poh_identity = @poh_identity and por_sequence <= @sequence
		update @working set por_sequence = @sequence where poh_identity = @poh_identity and por_sequence = @old_sequence
		select @poh_identity = max(poh_identity) from @working where poh_identity < @poh_identity 
	end
	select @sequence = max(por_sequence) from @working where por_sequence < @sequence
end

--select @sequence = max(por_sequence) from @working
--while @sequence is not null
--begin
--	select @stop_count = count(distinct por_origin) from @working where por_sequence = @sequence
--	if @stop_count > 1
--		insert into @results (por_origin, por_destination, por_sequence) values ('MULTIPLE', NULL, @sequence)
--	else
--		insert into @results (por_origin, por_destination, por_sequence) select distinct por_origin, NULL, @sequence from @working where por_sequence = @sequence
		
--	select @stop_count = count(distinct por_destination) from @working where por_sequence = @sequence
--	if @stop_count > 1
--		Update @results set por_destination = 'MULTIPLE' where por_sequence = @sequence
--	else
--		Update @results set por_destination = (select distinct por_destination from @working where por_sequence = @sequence) where por_sequence = @sequence
		
--	select @sequence = max(por_sequence) from @working where @sequence > por_sequence 
--end 

select por_origin, por_destination, por_sequence, poh_identity from @working order by poh_identity, por_sequence

GO
GRANT EXECUTE ON  [dbo].[d_partorder_massTLM_routes] TO [public]
GO
