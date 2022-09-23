SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Notes_UpdateAdd_sp](@Table char(18), @TableKeyValue char(18), @NoteText varchar(254), @NoteRegarding varchar(6), @AlertOrNote char(1), @NoteLevel varchar(6))
AS
BEGIN
/*Adds a note or alert
Parameters:
	@Table: 'orderheader' for orders
	@TableKeyValue: Header number
	@NoteText: Text for note
	@NoteRegarding: NoteRe Label values
	@AlertOrNote: 'A' = Alert, 'N' = Note
	@NoteLevel:  NoteLevel Label values

*/
-- 25551 SP created to generate report for order.

DECLARE @NextNoteID int
DECLARE @NextSequence int
DECLARE @mppID VARCHAR(25)
DECLARE @OldNoteText varchar(254)
DECLARE @OldNoteViewLevel varchar(6)

IF @Table = 'manpowerprofile'
BEGIN
	SET @mppID = ''
	SELECT @mppID = mpp_id FROM manpowerprofile WHERE mpp_otherid = @TableKeyValue
	IF ISNULL(@mppID, '') = ''
		SET @TableKeyValue = 'UNKNOWN'
	ELSE
		SET @TableKeyValue = @mppID		
END 
IF @TableKeyValue = 'UNKNOWN' RETURN


--Get the next sequence number
SELECT  @NextSequence = not_sequence,
		@OldNoteText =  not_text,
		@OldNoteViewLevel = not_viewlevel
FROM notes
WHERE ntb_table = @Table AND
	nre_tablekey = @TableKeyValue AND
	not_type = @NoteRegarding AND
	not_urgent = @AlertOrNote
	
 If @OldNoteText = @NoteText and @OldNoteViewLevel = @NoteLevel
return
  
IF @NextSequence IS NULL
	SELECT @NextSequence = ISNULL(MAX(not_sequence), 0) + 1
	FROM notes
	WHERE ntb_table = @Table AND
		nre_tablekey = @TableKeyValue
ELSE
	DELETE FROM notes
	WHERE ntb_table = @Table AND
	nre_tablekey = @TableKeyValue AND
	not_type = @NoteRegarding AND
	not_urgent = @AlertOrNote AND
	not_sequence = @NextSequence

exec @NextNoteID = getsystemnumber  'NOTES', NULL

INSERT INTO notes ( not_number, 
		not_text, 
		not_type, 
		not_urgent, 
		not_expires, 
		ntb_table, 
		nre_tablekey, 
		not_sequence, 
		not_text_large, 
		not_viewlevel ) 
VALUES ( @NextNoteID, 
	CAST(@NoteText as varchar(254)),
	@NoteRegarding, 
	@AlertOrNote, 
	'12-31-2049 23:59:0.000', 
	@Table, 
	@TableKeyValue, 
	@NextSequence, 
	@NoteText, 
	@NoteLevel)
END

GO
GRANT EXECUTE ON  [dbo].[Notes_UpdateAdd_sp] TO [public]
GO
