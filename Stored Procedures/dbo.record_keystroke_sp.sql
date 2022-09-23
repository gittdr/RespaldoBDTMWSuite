SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [dbo].[record_keystroke_sp] (@keystroke varchar(255))
as
Insert Into tts_keystrokes
(kys_keystroke, kys_date)
Select 
@keystroke, getdate()


GO
GRANT EXECUTE ON  [dbo].[record_keystroke_sp] TO [public]
GO
