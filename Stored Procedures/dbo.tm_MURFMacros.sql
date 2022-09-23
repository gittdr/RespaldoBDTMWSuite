SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* 09/18/01 MZ */
CREATE PROCEDURE [dbo].[tm_MURFMacros] @AuxIdSN int, @MCTSN int

AS

SET NOCOUNT ON 

    DECLARE @MURFSN int

    SET @MURFSN = 0
    SELECT @MURFSN = SN
    FROM tblQCMURF
    WHERE AuxSN = @AuxIdSN
        AND MCTSN = @MCTSN

    CREATE TABLE #t (FormID int, FormName varchar(25), Value int, Direction char(1))

    INSERT INTO #t (FormID, FormName, Value, Direction)
        SELECT b.ID, a.Name, 0, CASE a.Forward WHEN 1 THEN 'F' ELSE 'R' END
        FROM tblForms a (NOLOCK), tblselectedmobilecomm b (NOLOCK)
        WHERE a.Status = 'Current'
			AND a.SN = b.FormSN
			AND b.Status = 'Current'

	-- Add entries for forward/return text messages
    INSERT INTO #t (FormID, FormName, Value, Direction)
	VALUES (0, 'Free Form', 1, 'F')

    INSERT INTO #t (FormID, FormName, Value, Direction)
	VALUES (0, 'Free Form', 1, 'R')

    -- Now set value for each macro for this MURF
    UPDATE #t
    SET #t.Value = tblQCMURFForms.Value
    FROM tblQCMURFForms, #t
    WHERE #t.FormID = tblQCMURFForms.FormID
        AND #t.Direction = tblQCMURFForms.Direction
        AND tblQCMURFForms.MURFSN = @MURFSN

    -- Return the results
    SELECT FormId, FormName, Value, Direction
    FROM #t
    ORDER BY Direction, FormId
GO
GRANT EXECUTE ON  [dbo].[tm_MURFMacros] TO [public]
GO
