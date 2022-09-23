SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[getsystemnumber_gateway](@p_controlid varchar(8),
					 @p_alternateid varchar(8),
					 @p_reservenbr int)
AS
DECLARE	@v_controlnumber int,
	@v_return_number int, @v_rowcount int, @v_error int		

SELECT @p_reservenbr = ISNULL(@p_reservenbr,1)  -- If the nbr of reserved numbers wasn't set, default to 1
SELECT @p_alternateid = ISNULL(@p_alternateid, '')

--new code here--
DECLARE @v_sql nvarchar(500), @v_tablename nvarchar(50), @v_lastctrlnumber int, @v_firstctrlnumber int
SELECT @v_tablename = 'ident_' + rtrim(lower(@p_controlid))
IF @p_alternateid <> '' SELECT @v_tablename = @v_tablename + '_' + rtrim(lower(@p_alternateid))

Declare @OutputIdentity	int

IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[' + @v_tablename + ']') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
	--SELECT @v_firstctrlnumber = IDENT_CURRENT(@v_tablename)  /*Commented out for PTS 29452 CGK 8/26/2005,breaks in SQL 7.0 and is not needed for this procedure*/
	if @p_reservenbr > 1 	--block number, use tab lock with "insert into select"
	begin
		SELECT @v_sql = 'INSERT INTO ' + @v_tablename + ' with (TABLOCK) (id) SELECT id from ident_block where id < ' + convert(varchar(20), @p_reservenbr) + '; select @ident = SCOPE_IDENTITY()'
	end
	else	--only one number, use insert 
	begin
		SELECT @v_sql = 'INSERT INTO ' + @v_tablename + ' DEFAULT VALUES ; select @ident = scope_identity()'
	end
	
	-- PTS 62200 - MUST get the scope_identity from the executed SQL. It is not in the same scope
	--	as this proc.
	EXEC sp_executesql @v_sql, N'@ident int Output', @ident = @OutputIdentity output
	
	SELECT @v_error = @@error
	IF @v_error <> 0 RETURN @@error
	SELECT @v_lastctrlnumber = @OutputIdentity			--PTS 62200 - DJM - changed from using @@identity variable
	SELECT @v_firstctrlnumber = @v_lastctrlnumber - (@p_reservenbr - 1)	
	RETURN @v_firstctrlnumber
END
--end new code--

BEGIN TRAN SYSCONTROL 

-- Reserve a @p_reservenbr size block of numbers
UPDATE systemcontrol with (holdlock)
SET systemcontrol.sys_controlnumber = systemcontrol.sys_controlnumber + @p_reservenbr
FROM systemcontrol  
WHERE (systemcontrol.sys_controlid = @p_controlid) 
  AND (systemcontrol.sys_alternateparm = @p_alternateid) 
select @v_rowcount= @@rowcount, @v_error = @@error
IF @v_error != 0 GOTO ERROR_EXIT

if @v_rowcount = 0
   if left(@p_controlid,3) in ('ORD', 'MIV') --41961/43171 pmill	
   INSERT INTO systemcontrol(sys_controlid, sys_controlnumber, sys_description, 
		sys_alternateparm, sys_locked)
	VALUES(@p_controlid, 1, @p_controlid, '', 0)


-- Return the first number in the block to use
SELECT @v_return_number =  systemcontrol.sys_controlnumber - (@p_reservenbr - 1)
FROM systemcontrol 
WHERE (systemcontrol.sys_controlid = @p_controlid) 
  AND (systemcontrol.sys_alternateparm = @p_alternateid) 
select @v_rowcount= @@rowcount, @v_error = @@error

ERROR_EXIT:
IF @v_error != 0 
  BEGIN
	ROLLBACK TRAN SYSCONTROL
	SELECT @v_return_number = -1
  END
ELSE
	COMMIT TRAN SYSCONTROL 
	
RETURN @v_return_number

GO
GRANT EXECUTE ON  [dbo].[getsystemnumber_gateway] TO [public]
GO
