SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[notes_add_sp](@Table char(18), @TableKeyValue char(18), @NoteText Text, @NoteRegarding varchar(6), @AlertOrNote char(1), @NoteLevel varchar(6))
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

--Get the next sequence number
SELECT @NextSequence = ISNULL(MAX(not_sequence), 0) + 1
FROM notes
WHERE ntb_table = @Table AND
	nre_tablekey = @TableKeyValue

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
GRANT EXECUTE ON  [dbo].[notes_add_sp] TO [public]
GO
