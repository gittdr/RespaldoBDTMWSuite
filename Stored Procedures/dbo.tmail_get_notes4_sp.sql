SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_get_notes4_sp] @notetable varchar(18) = NULL, @tablekey varchar(18), @notetype varchar(75) = NULL, @wrapwidth varchar(20) = NULL 

AS

SET NOCOUNT ON 

	DECLARE @comments varchar(MAX), --100391 - Changed to MAX length.
			@len int, --100391 Changed from smallint to int which will not potentially overflow.
			@pos int, --100391 Changed from smallint to int which will not potentially overflow.
			@seq int, --100391 Changed from smallint to int which will not potentially overflow.
			@NoteNum int,
			@LastNoteNum int,
			@poscrlf int, --100391 Changed from smallint to int which will not potentially overflow.
			@temp varchar(255), 
			@OneLineNotes VARCHAR(MAX), --100391 - Changed to MAX length.
			@sn int,
			@SQLWork varchar(4000),
			@WorkTableKey varchar(20),
			@OrigNoteTable varchar(18),
			@WorkNumber int,
			@UseLargeNotes char(1),
			@attached_to varchar(20),
			@attached_to_key varchar(20),
			@regarding varchar(20),
			@commapos int,
			@qNoteType varchar(100),
			@iWrapWidth int,
			@iLinePerNote int
	
	CREATE TABLE #TableEntryListWithDups(NoteTable varchar(18), TableKey varchar(18))
	CREATE TABLE #TableEntryList(NoteTable varchar(18), TableKey varchar(18))
	CREATE TABLE #NoteList(NoteNum int, WorkSeq int)
	CREATE TABLE #t(notes varchar(255) NULL, 
			sn int identity, 
			NotesNoWrap VARCHAR(MAX) NULL, --100391 - Changed to MAX length.
			AttachedTo varchar(20) null,
			Regarding varchar(50) null,
			RegardingAbbr varchar(20) null,
			AttachedToKey varchar(20) null,
			NoteNum int null)	  -- Warning received IF over the row limit.

SELECT @UseLargeNotes = upper(substring(isnull(gi_string1,'N'),1 ,1)) FROM generalinfo WHERE gi_name = 'UseLargeNotes' 

IF isnumeric(@wrapwidth)<>0
	SELECT @iWrapWidth = CONVERT(int, @wrapwidth)
ELSE
	SELECT @iWrapWidth = 38

IF @iWrapWidth < 1 or @iWrapWidth > 255
	SELECT @iLinePerNote = 1
ELSE
	SELECT @iLinePerNote = 0
	
IF ISNULL(@notetable,'')='' AND ISNULL(@notetype,'')=''
	INSERT #NoteList VALUES( @tablekey, 1 )				-- VV 18494 just note key passed
ELSE
BEGIN
	SELECT @orignotetable = @notetable
	IF @notetable = 'order' or @notetable = 'orderset'
	-- Order number passed in (tablekey = order#).  switch to orderheader  (Same result IF passing in 'orderheader' directly.)
	BEGIN
		SELECT @WorkTableKey = ord_hdrnumber 
		FROM orderheader (NOLOCK)
		WHERE ord_number = @tablekey
		
		SELECT @tablekey = @WorkTableKey
		
		SELECT @notetable = 'orderheader'
	END -- jgf 8/25/03 {19579}

	INSERT INTO #TableEntryListWithDups (NoteTable, TableKey) VALUES (@notetable, @tablekey)

	IF @orignotetable = 'orderset' -- Also show all the notes that appear when you click the notes button in OE.
		BEGIN
		INSERT INTO #TableEntryListWithDups(NoteTable, TableKey)
		SELECT 'commodity', cmd_code 
		FROM orderheader (NOLOCK)
		WHERE ord_hdrnumber = @tablekey
		
		INSERT INTO #TableEntryListWithDups(NoteTable, TableKey)
		SELECT 'company', ord_billto 
		FROM orderheader (NOLOCK)
		WHERE ord_hdrnumber = @tablekey
		
		INSERT INTO #TableEntryListWithDups(NoteTable, TableKey)
		SELECT 'thirdpartyprofile', ord_thirdpartytype1 
		FROM orderheader (NOLOCK)
		WHERE ord_hdrnumber = @tablekey
		
		SELECT @WorkNumber = ISNULL(mov_number, 0) 
		FROM orderheader (NOLOCK)
		WHERE ord_hdrnumber = @tablekey
		
		IF @WorkNumber > 0
			BEGIN
			INSERT INTO #TableEntryListWithDups(NoteTable, TableKey) VALUES ('movement', CONVERT(varchar(18), @WorkNumber))
			INSERT INTO #TableEntryListWithDups(NoteTable, TableKey)
			SELECT 'company', cmp_id 
			FROM stops (NOLOCK)
			WHERE mov_number = @WorkNumber
			
			INSERT INTO #TableEntryListWithDups(NoteTable, TableKey)
			
			SELECT 'manpowerprofile', evt_driver1 
			FROM event (NOLOCK)
			INNER JOIN stops (NOLOCK) ON event.stp_number = stops.stp_number 
			WHERE stops.mov_number = @WorkNumber
			
			INSERT INTO #TableEntryListWithDups(NoteTable, TableKey)
			SELECT 'manpowerprofile', evt_driver2 
			FROM event (NOLOCK)
			INNER JOIN stops (NOLOCK) ON event.stp_number = stops.stp_number 
			WHERE stops.mov_number = @WorkNumber
			
			INSERT INTO #TableEntryListWithDups(NoteTable, TableKey)
			SELECT 'tractorprofile', evt_tractor 
			FROM event (NOLOCK)
			INNER JOIN stops (NOLOCK) ON event.stp_number = stops.stp_number 
			WHERE stops.mov_number = @WorkNumber
			
			INSERT INTO #TableEntryListWithDups(NoteTable, TableKey)
			SELECT 'trailerprofile', lgh_primary_trailer 
			FROM legheader (NOLOCK)
			WHERE mov_number = @WorkNumber
			
			INSERT INTO #TableEntryListWithDups(NoteTable, TableKey)
			SELECT 'trailerprofile', evt_trailer2 
			FROM event (NOLOCK)
			INNER JOIN stops (NOLOCK) ON event.stp_number = stops.stp_number 
			WHERE stops.mov_number = @WorkNumber
			
			INSERT INTO #TableEntryListWithDups(NoteTable, TableKey)
			SELECT 'carrierprofile', evt_carrier 
			FROM event (NOLOCK)
			INNER JOIN stops (NOLOCK) ON event.stp_number = stops.stp_number 
			WHERE stops.mov_number = @WorkNumber
			
			INSERT INTO #TableEntryListWithDups(NoteTable, TableKey)
			SELECT 'commodity', cmd_code 
			FROM stops (NOLOCK) 
			WHERE mov_number = @WorkNumber
			
			END
		DELETE FROM #TableEntryListWithDups WHERE ISNULL(TableKey, '') = ''
		DELETE FROM #TableEntryListWithDups WHERE ISNULL(TableKey, 'UNKNOWN') = 'UNKNOWN'
		END
	
	INSERT INTO #TableEntryList (NoteTable, TableKey) SELECT DISTINCT NoteTable, TableKey FROM #TableEntryListWithDups 

	IF @NoteType = ''
		BEGIN
			INSERT INTO #NoteList (NoteNum, WorkSeq) 
			SELECT not_number, not_sequence 
			FROM notes (NOLOCK) 
			INNER JOIN #TableEntryList ON notes.ntb_table = #TableEntryList.NoteTable
				AND notes.nre_tablekey = #TableEntryList.TableKey
		END
	ELSE IF CHARINDEX(',', @NoteType) <> 0
		BEGIN
			-- Parse the NoteType string and add quotes
			SET @commapos = 0
			SET @qNoteType = ''

			SELECT @commapos = CHARINDEX(',', @NoteType)	
			WHILE @commapos > 0
			  BEGIN
				SET @qNoteType = @qNoteType + '''' + LEFT (@NoteType,@commapos -1) + '''' + ','
				SET @NoteType = RIGHT(@NoteType, LEN(@NoteType) - @commapos)
	
				SELECT @commapos = CHARINDEX(',', @NoteType)	
			  END

			IF @NoteType <> ''
				SET @qNoteType = @qNoteType + '''' + @NoteType + '''' + ','				

			IF (RIGHT (@qNoteType,1) = ',')
				SET @qNoteType = LEFT(@qNoteType, LEN(@qNoteType) -1)

			SELECT @SQLWork = 'SELECT not_number, not_sequence FROM notes' -- Start with the first sequence of notes with this table/key value.
			SELECT @SQLWork = @SQLWork + ' INNER JOIN #TableEntryList'
			SELECT @SQLWork = @SQLWork + ' ON ntb_table = #TableEntryList.NoteTable'
			SELECT @SQLWork = @SQLWork + ' AND nre_tablekey = #TableEntryList.TableKey'
			SELECT @SQLWork = @SQLWork + ' WHERE not_type IN (' + @qNoteType + ')'
			INSERT INTO #NoteList (NoteNum, WorkSeq) EXEC (@SQLWork)
		END
	ELSE   -- Note type examples: T, E, CMD, C, S, D, NONE, B, R, CA, NULL, P
		BEGIN
			INSERT INTO #NoteList (NoteNum, WorkSeq) 
			SELECT not_number, not_sequence 
			FROM notes (NOLOCK) -- Start with the first sequence of notes with this table/key value.
			INNER JOIN #TableEntryList ON
				ntb_table = #TableEntryList.NoteTable
				AND nre_tablekey = #TableEntryList.TableKey
			WHERE not_type = @NoteType
		END

	SELECT @OneLineNotes = ''
END

	SELECT @seq = MIN(WorkSeq) FROM #NoteList	
	SELECT @NoteNum = min(NoteNum) 
	FROM #NoteList 
	WHERE WorkSeq = @seq
	WHILE ISNULL(@NoteNum, 0) > 0   -- Loop through each note.
		BEGIN
			IF @UseLargeNotes='Y'
				SELECT @attached_to = ntb_table, @attached_to_key = nre_tablekey, @regarding = not_type, @comments = isnull(CAST(not_text_large AS varchar(MAX)), '')  --100391 - Changed to accomodate new varchar Max. Also got rid of unnecessary substring.
				FROM Notes (NOLOCK)
				WHERE not_number = @NoteNum  -- Get notes FROM this record.
			ELSE
				SELECT @attached_to = ntb_table, @attached_to_key = nre_tablekey, @regarding = not_type, @comments = isnull(CAST(not_text AS varchar(MAX)), '') --100391 - Changed to accomodate new varchar Max.
				FROM Notes (NOLOCK) 
				WHERE not_number = @NoteNum  -- Get notes FROM this record.

			-- THIS BUILDS THE NORMAL NOTES.
			IF @iLinePerNote <> 0
				INSERT #t (notes, attachedto, regarding, regardingabbr, attachedtokey, NoteNum) VALUES (substring (@comments, 1, 255), @attached_to, 
				@regarding, @regarding, @attached_to_key, @NoteNum)
			ELSE
				BEGIN
				SELECT @len = datalength(RTRIM(@comments)), @pos = 1
				WHILE (@pos < @len) -- Break notes up into 38 character blocks.
					BEGIN
						SELECT @poscrlf = 0
						SELECT @poscrlf = CHARINDEX(CHAR(13)+CHAR(10), substring(@comments, @pos, @iWrapWidth + 2))
						IF ISNULL(@poscrlf, 0) > 0
							BEGIN
								INSERT #t (notes, attachedto, regarding, regardingabbr, attachedtokey, NoteNum) VALUES (substring (@comments, 
								@pos, @poscrlf - 1), @attached_to, @regarding, @regarding, @attached_to_key, @NoteNum)
								SELECT @pos = @pos + @poscrlf + 1
							END
						ELSE
							BEGIN
								INSERT #t (notes, attachedto, regarding, regardingabbr, attachedtokey, NoteNum) VALUES (substring ( @comments, @pos, @iWrapWidth ), 
								@attached_to, @regarding, @regarding, @attached_to_key, @NoteNum)
								SELECT @pos = @pos + @iWrapWidth
							END
					END
				END

			-- THIS BUILDS THE ONE LINE NOTES.
			-- Seperate lines of notes with CRLF for each sequence number, or IF a blank line was intentionally put in by user for a specIFic sequence.
			IF (@comments = '')
				SELECT @OneLineNotes = @OneLineNotes + CHAR(13) + CHAR(10) 
			ELSE 
				BEGIN
				IF (LEN(@OneLineNotes) > 0) 
					BEGIN
					IF (RIGHT(@OneLineNotes, 1) = CHAR(10))
						SELECT @OneLineNotes = RTRIM(@OneLineNotes) + RTRIM(LTRIM(@comments))
					ELSE
						SELECT @OneLineNotes = RTRIM(@OneLineNotes) + ' ' + RTRIM(LTRIM(@comments))
					END
				ELSE
					SELECT @OneLineNotes = LTRIM(RTRIM(@comments))
				END

         -- Determine next note. 
			SELECT @LastNoteNum = @NoteNum 
			SELECT @NoteNum = 0
			SELECT @NoteNum = MIN(NoteNum) FROM #NoteList 
			WHERE WorkSeq = @seq AND NoteNum > @LastNoteNum

			IF IsNull(@NoteNum, 0) = 0
				BEGIN
					SELECT @seq = MIN(WorkSeq) FROM #NoteList 
					WHERE WorkSeq > @seq
					SELECT @NoteNum = MIN(NoteNum) FROM #NoteList 
					WHERE WorkSeq = @seq
					IF (ISNULL(@NoteNum, 0) > 0) SELECT @OneLineNotes = @OneLineNotes + CHAR(13) + CHAR(10) 	
				END
		END  -- END of WHILE
		
	IF len(ltrim(@OneLineNotes)) > 0 	-- jgf 8/27/03 bug fix, included in {19579}
		BEGIN	
			UPDATE #t SET NotesNoWrap = LTRIM(RTRIM(@OneLineNotes))
			
			SELECT @seq = 0
			SELECT @seq = COUNT(*) FROM #t
			IF (@Seq = 0) INSERT INTO #t (notes) VALUES ('')
		END 				-- jgf 8/27/03 bug fix, included in {19579}

	UPDATE #t set Regarding=l.name FROM #t, labelfile l WHERE l.abbr=#t.RegardingAbbr and l.labeldefinition='NoteRe'

	SELECT Notes, NotesNoWrap, AttachedTo, Regarding, RegardingAbbr, AttachedToKey, NoteNum FROM #t 
		
	DROP TABLE #t
GO
GRANT EXECUTE ON  [dbo].[tmail_get_notes4_sp] TO [public]
GO
