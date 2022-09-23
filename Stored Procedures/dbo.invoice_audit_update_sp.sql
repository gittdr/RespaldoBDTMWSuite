SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[invoice_audit_update_sp]
	@ivh_hdrnumber		int,
	@image_received_datetime	datetime,				-- 69320
	@action				varchar(10),
	@errortext			varchar(650) output		-- MAX(len(text)) from sys.messages is 651
as

/**
 * 
 * NAME:	dbo.invoice_audit_update_sp
 * TYPE:	StoredProcedure
 * DESCRIPTION:	
 *			This is stored procedure developed for CR England per their specification and requirement.
 *			It is called by their audit system 'Synergize' to update invoiceheader properly and produce an 
 *			EDI output file for EDI ONLY bill to when approving the invoice.
 *
 * REVISION HISTORY:
 * 01/31/13	NQIAO PTS64565 initially developed
 * 07/03/13 NQIAO PTS69320 add new input @image_received_datetime to compare to invoiceheader.last_updatedate *
 **/
 
declare	@ivh_invoicestatus	varchar(6),
		@ivh_billto			varchar(8),
		@ivh_definition		varchar(6),
		@cmp_edi210			int,
		@returncode			int,
		@last_updatedate	datetime		-- 69320



select @returncode = 0	-- inital value

select	@ivh_invoicestatus = ivh_invoicestatus,
		@ivh_billto = ivh_billto,
		@ivh_definition = ivh_definition,
		@last_updatedate = last_updatedate	-- 69320
from	invoiceheader
where	ivh_hdrnumber = @ivh_hdrnumber
	
-- invoice not found	
if @@ROWCOUNT = 0	
begin
	select	@returncode = 1,
			@errortext = 'Invoice does not exist.'
			
	return	@returncode
end

select	@cmp_edi210 = isnull(cmp_edi210, 0)
from	company
where	cmp_id = @ivh_billto

-- approve invoice
if @action = 'APPROVE'		
begin
	if @ivh_invoicestatus = 'RTP'
	begin
		if (@last_updatedate is not null) and (@last_updatedate > @image_received_datetime)		-- 69320
		begin
			select	@returncode = 5,
					@errortext = 'Cannot approve this invoice that has been changed since printing.'
			return	@returncode
		end
		
		update	invoiceheader
		set		ivh_printdate = GETDATE(),
				ivh_invoicestatus = 'PRN'
		where	ivh_hdrnumber = @ivh_hdrnumber


		if @@ERROR = 0				-- update successful
		begin
			if (@cmp_edi210 = 1) or (@cmp_edi210 = 2) or (@cmp_edi210 = 3 and @ivh_definition <> 'RBIL')	-- create EDI output file for EDI ONLY bill to
				execute @returncode = edi_210_version_sp @ivh_hdrnumber
				
			if @returncode <> 0
			begin
				select	@errortext = 'Failed to create EDI output file.  ' + text
				from	sys.messages 
				where	message_id	= @returncode
				and		language_id = 1033	
				
				return	@returncode
			end
		end
		else
		begin
			select	@returncode = @@ERROR,
					@errortext = text
			from	sys.messages 
			where	message_id = @@error
			and		language_id = 1033		
		
			return @returncode
		end
	end
	else  -- the staus must be RTP
	begin
		select	@returncode = 2,
				@errortext = 'Invoice with status ' + @ivh_invoicestatus + ' cannot be approved.  The status must be RTP.'
		return	@returncode
	end
end
	
-- reject invoice	
if @action = 'REJECT'
begin 
	if @ivh_invoicestatus = 'RTP'
	begin
		update	invoiceheader
		set		ivh_printdate = null,
				ivh_invoicestatus = 'HLA'
		where	ivh_hdrnumber = @ivh_hdrnumber
		
		if @@ERROR <> 0 
		begin
			select	@returncode = @@ERROR,
					@errortext = text
			from	sys.messages 
			where	message_id = @@error
			and		language_id = 1033		
		
			return	@returncode
		end
	end
	else  -- the staus must be RTP
	begin
		select	@returncode = 3,
				@errortext = 'Invoice with status ' + @ivh_invoicestatus + ' cannot be rejected.  The status must be RTP.'
		return	@returncode
	end
end


-- print invoice
if @action = 'PRINT'
begin
	if @ivh_invoicestatus = 'PRN'
	begin
		update	invoiceheader
		set		ivh_lastprintdate = GETDATE()
		where	ivh_hdrnumber = @ivh_hdrnumber
		
		if @@ERROR <> 0	
		begin			
			select	@returncode = @@ERROR,
					@errortext = text
			from	sys.messages 
			where	message_id = @@error
			and		language_id = 1033		
		
			return @returncode
		end
	end
	else  -- the staus must be PRN
	begin
		select	@returncode = 4,
				@errortext = 'Invoice with status ' + @ivh_invoicestatus + ' cannot be printed.  The status must be PRN.'
				
		return	@returncode
	end
end


GO
GRANT EXECUTE ON  [dbo].[invoice_audit_update_sp] TO [public]
GO
