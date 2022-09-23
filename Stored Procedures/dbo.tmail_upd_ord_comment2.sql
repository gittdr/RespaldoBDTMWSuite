SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_upd_ord_comment2](
   @not_number INT,
   @ordnum VARCHAR (12),
   @comment VARCHAR(254),
   @prefix VARCHAR(30),
   @suffix VARCHAR(30),
   @Flags VARCHAR(12),
   @NoteType VARCHAR(6)
)
AS

SET NOCOUNT ON 

/* 05/24/01 DAG: Converting for international date format */

   DECLARE @sTemp VARCHAR(255)
   DECLARE @not_text VARCHAR(254), @not_type VARCHAR(6), @not_urgent CHAR(1), @ntb_table VARCHAR(30), @nre_tablekey VARCHAR(18), @not_sequence INT, @not_expires DATETIME
   DECLARE @iFlags int

   -- Convert the @Flags to an int so we can do math on it
   --  This is mainly for SQL Server 6.5 users
   SET @iFlags = CONVERT(int,ISNULL(@Flags,'0'))

   --DWG - Set alert flag when inserting record
   SET @not_urgent = 'N'
   IF (@iFlags & 1) <> 0
	SET @not_urgent = 'A'
	
   --DWG - Set Note Type of 'NONE' if null or blank
   SELECT @NoteType = ISNULL(@NoteType, '')
   IF @NoteType = ''
     SELECT @NoteType = 'NONE'

   IF (EXISTS(SELECT ord_number FROM OrderHeader (NOLOCK) WHERE ord_number = @ordnum) AND LEN(@comment) > 0)
   BEGIN
      /*** Set up values to be inserted ***/
      SELECT @not_text     =   CASE WHEN @prefix IS NULL THEN '' ELSE @prefix END + @comment + CASE WHEN @suffix IS NULL THEN '' ELSE @suffix END,  
             @not_type      = @NoteType,
             @not_expires  = '20491231 23:59:00.000', 
             @ntb_table      = 'orderheader', 
             @nre_tablekey = CONVERT(VARCHAR(18), ord_hdrnumber) 
         FROM OrderHeader (NOLOCK)
         WHERE ord_number = @ordnum

      SELECT @not_sequence = CASE WHEN MAX(not_sequence) IS NULL THEN 1 ELSE MAX(not_sequence) + 1 END
         FROM notes (NOLOCK)
         WHERE ntb_table = @ntb_table AND nre_tablekey = @nre_tablekey 

      /*** Insert now ***/
      INSERT INTO notes
         (not_number,   not_text,  not_type,  not_urgent,  not_expires,  ntb_table,  nre_tablekey,  not_sequence)
      VALUES                                                                                                
         (@not_number, @not_text, @not_type, @not_urgent, @not_expires, @ntb_table, @nre_tablekey, @not_sequence)


   END





GO
GRANT EXECUTE ON  [dbo].[tmail_upd_ord_comment2] TO [public]
GO
