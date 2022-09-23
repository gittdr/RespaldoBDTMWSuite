SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [dbo].[order_stp_cmp_id_shell_sp] 
	(	@ord_hdrnumber int, 
		@cmp_id varchar(8), 
		@parmlist varchar(254) = null
	)

  
AS BEGIN    
	DECLARE	@proc_to_call	varchar(50)
	--parms in the form of parm1=value1,parm2=value2
	--If needed, pass additional parameters in this way.  This will allow existing client custom procedures to function.
	
	--Get procedure to call 
	SELECT	@proc_to_call = isnull(ltrim(rtrim(gi_string1)), '') 
	FROM	generalinfo 
	WHERE	gi_name = 'OrderStopCmpIDValidation'

	if ISNULL(@proc_to_call, '') = '' BEGIN
		--Return ok
		SELECT	0,
				''
	END 
	ELSE BEGIN
		EXEC	@proc_to_call
			@ord_hdrnumber,
			@cmp_id,
			@parmlist
	END
  
END 
GO
GRANT EXECUTE ON  [dbo].[order_stp_cmp_id_shell_sp] TO [public]
GO
