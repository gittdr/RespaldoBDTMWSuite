SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [dbo].[dx_GetExistingOrderHeaderNumber] (
@dx_ordernumber varchar(30),
@trp_id varchar (30),
@EDIRefType varchar(3),
@documentNumber varchar(30) OUTPUT,
@ord_startdate datetime
)
AS
	declare @dx_orderhdrnumber int
	SET @dx_orderhdrnumber = 0
		
    SELECT top 1 @dx_orderhdrnumber = dx_orderhdrnumber,
				@documentNumber = dx_docnumber
    FROM dx_archive_header (nolock) join orderheader (nolock) on dx_orderhdrnumber = ord_hdrnumber
    WHERE dx_importid = 'dx_204'
    AND dx_ordernumber = @dx_ordernumber
    and dx_processed = 'DONE'
    AND dx_orderhdrnumber > 0
    AND dx_updated <> 'C'  
    AND dx_trpid = ISNULL(@trp_id,dx_trpid)
    AND dx_sourcedate = (select MAX(dx_sourcedate) 
    FROM dx_archive_header WITH (NOLOCK)
    WHERE dx_importid = 'dx_204'
    AND dx_ordernumber = @dx_ordernumber
    AND dx_orderhdrnumber > 0
	and dx_processed = 'DONE'
    AND dx_updated <> 'C'  
    AND dx_trpid = ISNULL(@trp_id,dx_trpid))

If  @dx_orderhdrnumber = 0       
        BEGIN
			DECLARE @RC int
			DECLARE @ref varchar(6)
			DECLARE @sid varchar(30)
			DECLARE @max_update_status varchar(6)
			DECLARE @@ord_number varchar(12)
			DECLARE @@ord_hdrnumber int
			DECLARE @@updateflag char(1)
			DECLARE @@updatemsg varchar(50)
			DECLARE @@ord_status varchar(6)

-- TODO: Set parameter values here.
			Set @ref = @EDIRefType
			set @sid = @dx_ordernumber
			set @max_update_status = 'AVL'
			IF (SELECT COUNT(1) FROM dx_lookup
				WHERE dx_importid = 'dx_204' and dx_lookuptable = 'LtslSettings' 
				and dx_lookuprawdatavalue = 'AllowStartedUpdates' and dx_lookuptranslatedvalue = '1') = 1     
				set @max_update_status = 'STD'
			ELSE
				IF (SELECT COUNT(1) FROM dx_lookup
					WHERE dx_importid = 'dx_204' and dx_lookuptable = 'LtslSettings' 
					and dx_lookuprawdatavalue = 'AllowDispatchUpdates' and dx_lookuptranslatedvalue = '1') = 1     
					set @max_update_status = 'DSP'
				ELSE
					IF (SELECT COUNT(1) FROM dx_lookup
					WHERE dx_importid = 'dx_204' and dx_lookuptable = 'LtslSettings' 
					and dx_lookuprawdatavalue = 'NoPlnChanges' and dx_lookuptranslatedvalue = '1') = 0     
					set @max_update_status = 'PLN'
				print 'calling getupdate status'
			EXECUTE @RC = [dbo].[dx_get_update_status_from_sid] 
			   @ref
			  ,@sid
			  ,@trp_id
			  ,@ord_startdate
			  ,@max_update_status
			  ,@@ord_number OUTPUT
			  ,@@ord_hdrnumber OUTPUT
			  ,@@updateflag OUTPUT
			  ,@@updatemsg OUTPUT
			  ,@@ord_status OUTPUT
			  
			if @@updateflag = 'Y'
				set @dx_orderhdrnumber = @@ord_hdrnumber
		END
		

		RETURN @dx_orderhdrnumber

GO
GRANT EXECUTE ON  [dbo].[dx_GetExistingOrderHeaderNumber] TO [public]
GO
