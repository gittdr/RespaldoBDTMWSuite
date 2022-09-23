SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[update_completion_refnums_sp]	
@p_refnum1 varchar(30),
@p_refnum2 varchar(30),
@p_refnum3 varchar(30),
@p_refnum4 varchar(30),
@p_ord_hdrnumber int

AS

/**
 * 
 * NAME:
 * update_completion_refnums_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * 
 * RETURNS: NONE
 *
 * RESULT SETS: NONE
 *
 * PARAMETERS: 	@p_refnum1 		varchar(30)	Refnum 1 to update referencenumber table
 * 		@p_refnum2 		varchar(30)	Refnum 2 to update referencenumber table
 * 		@p_refnum3 		varchar(30)	Refnum 3 to update referencenumber table
 * 		@p_refnum4 		varchar(30)	Refnum 4 to update referencenumber table
 *		@p_ord_hdrnumber	int		Order Header Number to be updated
 *
 * REVISION HISTORY:
 * 7/13/2006.01 ? PTS33397 - Dan Hudec ? Created Procedure
 * 03/31/2011 PTS 56334 SPN now on we are using referencenumber table instead of completion_referencenumber
 *
 **/

DECLARE	@v_gi_ref1	varchar(60),
	@v_gi_ref2	varchar(60),
	@v_gi_ref3	varchar(60),
	@v_gi_ref4	varchar(60),
	@v_ref_sequence int,
	@v_tmwuser varchar(255)

exec gettmwuser @v_tmwuser output

SELECT	@v_gi_ref1 = gi_string1, 
	@v_gi_ref2 = gi_string2, 
	@v_gi_ref3 = gi_string3, 
	@v_gi_ref4 = gi_string4
FROM	generalinfo
WHERE	gi_name = 'OrdCompletionRefDisplay'

--Either insert row or delete row depending on whether or not refnum of the specified type already exists

--Reference Number 1
If @p_refnum1 IS NOT NULL
BEGIN
--BEGIN PTS 56334 SPN
--	IF EXISTS (SELECT * FROM completion_referencenumber 
--		    WHERE ref_tablekey = @p_ord_hdrnumber
--		    AND   ref_table = 'orderheader'
--		    AND   ord_hdrnumber = @p_ord_hdrnumber
--		    AND   ref_type = @v_gi_ref1)
-- 	 BEGIN
--		IF rtrim(ltrim(@p_refnum1)) <> ''
--		 BEGIN
--			UPDATE 	completion_referencenumber
--			SET	ref_number = @p_refnum1
--			WHERE	ref_tablekey = @p_ord_hdrnumber
--			AND 	ref_table = 'orderheader'
--			AND 	ord_hdrnumber = @p_ord_hdrnumber
--			AND 	ref_type = @v_gi_ref1
--			AND		ref_sequence = (select min(ref_sequence) from completion_referencenumber
--									where ref_tablekey = @p_ord_hdrnumber
--									AND 	ref_table = 'orderheader'
--									AND 	ord_hdrnumber = @p_ord_hdrnumber
--									AND 	ref_type = @v_gi_ref1)
--		 END
--		ELSE
--		 BEGIN
--			DELETE FROM completion_referencenumber
--			WHERE	ref_tablekey = @p_ord_hdrnumber
--			AND		ref_table = 'orderheader'
--			AND		ord_hdrnumber = @p_ord_hdrnumber
--			AND		ref_type = @v_gi_ref1
--			AND		ref_sequence = (select min(ref_sequence) from completion_referencenumber
--									where ref_tablekey = @p_ord_hdrnumber
--									AND 	ref_table = 'orderheader'
--									AND 	ord_hdrnumber = @p_ord_hdrnumber
--									AND 	ref_type = @v_gi_ref1)
--		 END
-- 	 END
--
--	ELSE
--	 BEGIN
--		SELECT	@v_ref_sequence = max(ref_sequence)
--		FROM	completion_referencenumber
--		WHERE	ref_tablekey = @p_ord_hdrnumber
--		AND		ref_table = 'orderheader'
--		AND		ord_hdrnumber = @p_ord_hdrnumber
--
--		If @v_ref_sequence IS NULL
--			Select @v_ref_sequence = 1
--		Else
--			Select @v_ref_sequence = @v_ref_sequence + 1
--
--		INSERT INTO completion_referencenumber
--		(ref_tablekey, ref_type, ref_number, ref_sequence, 
--		 ord_hdrnumber, ref_table, last_updateby, last_updatedate)
--		VALUES
--		(@p_ord_hdrnumber, @v_gi_ref1, @p_refnum1, @v_ref_sequence,
--		 @p_ord_hdrnumber, 'orderheader', @v_tmwuser, getdate())
--	 END
	IF EXISTS (SELECT * FROM referencenumber 
		    WHERE ref_tablekey = @p_ord_hdrnumber
		    AND   ref_table = 'orderheader'
		    AND   ord_hdrnumber = @p_ord_hdrnumber
		    AND   ref_type = @v_gi_ref1)
 	 BEGIN
		IF rtrim(ltrim(@p_refnum1)) <> ''
		 BEGIN
			UPDATE 	referencenumber
			SET	ref_number = @p_refnum1
			WHERE	ref_tablekey = @p_ord_hdrnumber
			AND 	ref_table = 'orderheader'
			AND 	ord_hdrnumber = @p_ord_hdrnumber
			AND 	ref_type = @v_gi_ref1
			AND		ref_sequence = (select min(ref_sequence) from referencenumber
									where ref_tablekey = @p_ord_hdrnumber
									AND 	ref_table = 'orderheader'
									AND 	ord_hdrnumber = @p_ord_hdrnumber
									AND 	ref_type = @v_gi_ref1)
		 END
		ELSE
		 BEGIN
			DELETE FROM referencenumber
			WHERE	ref_tablekey = @p_ord_hdrnumber
			AND		ref_table = 'orderheader'
			AND		ord_hdrnumber = @p_ord_hdrnumber
			AND		ref_type = @v_gi_ref1
			AND		ref_sequence = (select min(ref_sequence) from referencenumber
									where ref_tablekey = @p_ord_hdrnumber
									AND 	ref_table = 'orderheader'
									AND 	ord_hdrnumber = @p_ord_hdrnumber
									AND 	ref_type = @v_gi_ref1)
		 END
 	 END

	ELSE
	 BEGIN
		SELECT	@v_ref_sequence = max(ref_sequence)
		FROM	referencenumber
		WHERE	ref_tablekey = @p_ord_hdrnumber
		AND		ref_table = 'orderheader'
		AND		ord_hdrnumber = @p_ord_hdrnumber

		If @v_ref_sequence IS NULL
			Select @v_ref_sequence = 1
		Else
			Select @v_ref_sequence = @v_ref_sequence + 1

		INSERT INTO referencenumber
		(ref_tablekey, ref_type, ref_number, ref_sequence, 
		 ord_hdrnumber, ref_table, last_updateby, last_updatedate)
		VALUES
		(@p_ord_hdrnumber, @v_gi_ref1, @p_refnum1, @v_ref_sequence,
		 @p_ord_hdrnumber, 'orderheader', @v_tmwuser, getdate())
	 END
--END PTS 56334 SPN
END
--Reference Number 1

--Reference Number 2
If @p_refnum2 IS NOT NULL
--If rtrim(ltrim(@p_refnum2)) <> ''
BEGIN
--BEGIN PTS 56334 SPN
--	IF EXISTS (SELECT * FROM completion_referencenumber 
--		    WHERE ref_tablekey = @p_ord_hdrnumber
--		    AND   ref_table = 'orderheader'
--		    AND   ord_hdrnumber = @p_ord_hdrnumber
--		    AND   ref_type = @v_gi_ref2)
-- 	 BEGIN
--		IF rtrim(ltrim(@p_refnum2)) <> ''
--		 BEGIN
--			UPDATE 	completion_referencenumber
--			SET	ref_number = @p_refnum2
--			WHERE	ref_tablekey = @p_ord_hdrnumber
--			AND 	ref_table = 'orderheader'
--			AND 	ord_hdrnumber = @p_ord_hdrnumber
--			AND 	ref_type = @v_gi_ref2
--			AND		ref_sequence = (select min(ref_sequence) from completion_referencenumber
--									where ref_tablekey = @p_ord_hdrnumber
--									AND 	ref_table = 'orderheader'
--									AND 	ord_hdrnumber = @p_ord_hdrnumber
--									AND 	ref_type = @v_gi_ref2)
--		 END
--		ELSE
--		 BEGIN
--			DELETE FROM completion_referencenumber
--			WHERE	ref_tablekey = @p_ord_hdrnumber
--			AND		ref_table = 'orderheader'
--			AND		ord_hdrnumber = @p_ord_hdrnumber
--			AND		ref_type = @v_gi_ref2
--			AND		ref_sequence = (select min(ref_sequence) from completion_referencenumber
--									where ref_tablekey = @p_ord_hdrnumber
--									AND 	ref_table = 'orderheader'
--									AND 	ord_hdrnumber = @p_ord_hdrnumber
--									AND 	ref_type = @v_gi_ref2)
--		 END
-- 	 END
--
--	ELSE
--	 BEGIN
--		SELECT	@v_ref_sequence = max(ref_sequence)
--		FROM	completion_referencenumber
--		WHERE	ref_tablekey = @p_ord_hdrnumber
--		AND		ref_table = 'orderheader'
--		AND		ord_hdrnumber = @p_ord_hdrnumber
--
--		If @v_ref_sequence IS NULL
--			Select @v_ref_sequence = 1
--		Else
--			Select @v_ref_sequence = @v_ref_sequence + 1
--
--		INSERT INTO completion_referencenumber
--		(ref_tablekey, ref_type, ref_number, ref_sequence, 
--		 ord_hdrnumber, ref_table, last_updateby, last_updatedate)
--		VALUES
--		(@p_ord_hdrnumber, @v_gi_ref2, @p_refnum2, @v_ref_sequence,
--		 @p_ord_hdrnumber, 'orderheader', @v_tmwuser, getdate())
--	 END
	IF EXISTS (SELECT * FROM referencenumber 
		    WHERE ref_tablekey = @p_ord_hdrnumber
		    AND   ref_table = 'orderheader'
		    AND   ord_hdrnumber = @p_ord_hdrnumber
		    AND   ref_type = @v_gi_ref2)
 	 BEGIN
		IF rtrim(ltrim(@p_refnum2)) <> ''
		 BEGIN
			UPDATE 	referencenumber
			SET	ref_number = @p_refnum2
			WHERE	ref_tablekey = @p_ord_hdrnumber
			AND 	ref_table = 'orderheader'
			AND 	ord_hdrnumber = @p_ord_hdrnumber
			AND 	ref_type = @v_gi_ref2
			AND		ref_sequence = (select min(ref_sequence) from referencenumber
									where ref_tablekey = @p_ord_hdrnumber
									AND 	ref_table = 'orderheader'
									AND 	ord_hdrnumber = @p_ord_hdrnumber
									AND 	ref_type = @v_gi_ref2)
		 END
		ELSE
		 BEGIN
			DELETE FROM referencenumber
			WHERE	ref_tablekey = @p_ord_hdrnumber
			AND		ref_table = 'orderheader'
			AND		ord_hdrnumber = @p_ord_hdrnumber
			AND		ref_type = @v_gi_ref2
			AND		ref_sequence = (select min(ref_sequence) from referencenumber
									where ref_tablekey = @p_ord_hdrnumber
									AND 	ref_table = 'orderheader'
									AND 	ord_hdrnumber = @p_ord_hdrnumber
									AND 	ref_type = @v_gi_ref2)
		 END
 	 END

	ELSE
	 BEGIN
		SELECT	@v_ref_sequence = max(ref_sequence)
		FROM	referencenumber
		WHERE	ref_tablekey = @p_ord_hdrnumber
		AND		ref_table = 'orderheader'
		AND		ord_hdrnumber = @p_ord_hdrnumber

		If @v_ref_sequence IS NULL
			Select @v_ref_sequence = 1
		Else
			Select @v_ref_sequence = @v_ref_sequence + 1

		INSERT INTO referencenumber
		(ref_tablekey, ref_type, ref_number, ref_sequence, 
		 ord_hdrnumber, ref_table, last_updateby, last_updatedate)
		VALUES
		(@p_ord_hdrnumber, @v_gi_ref2, @p_refnum2, @v_ref_sequence,
		 @p_ord_hdrnumber, 'orderheader', @v_tmwuser, getdate())
	 END
--END PTS 56334 SPN
END
--Reference Number 2

--Reference Number 3
If @p_refnum3 IS NOT NULL
--If rtrim(ltrim(@p_refnum3)) <> ''
BEGIN
--BEGIN PTS 56334 SPN
--	IF EXISTS (SELECT * FROM completion_referencenumber 
--		    WHERE ref_tablekey = @p_ord_hdrnumber
--		    AND   ref_table = 'orderheader'
--		    AND   ord_hdrnumber = @p_ord_hdrnumber
--		    AND   ref_type = @v_gi_ref3)
-- 	 BEGIN
--		IF rtrim(ltrim(@p_refnum3)) <> ''
--		 BEGIN
--			UPDATE 	completion_referencenumber
--			SET	ref_number = @p_refnum3
--			WHERE	ref_tablekey = @p_ord_hdrnumber
--			AND 	ref_table = 'orderheader'
--			AND 	ord_hdrnumber = @p_ord_hdrnumber
--			AND 	ref_type = @v_gi_ref3
--			AND		ref_sequence = (select min(ref_sequence) from completion_referencenumber
--									where ref_tablekey = @p_ord_hdrnumber
--									AND 	ref_table = 'orderheader'
--									AND 	ord_hdrnumber = @p_ord_hdrnumber
--									AND 	ref_type = @v_gi_ref3)
--		 END
--		ELSE
--		 BEGIN
--			DELETE FROM completion_referencenumber
--			WHERE	ref_tablekey = @p_ord_hdrnumber
--			AND		ref_table = 'orderheader'
--			AND		ord_hdrnumber = @p_ord_hdrnumber
--			AND		ref_type = @v_gi_ref3
--			AND		ref_sequence = (select min(ref_sequence) from completion_referencenumber
--									where ref_tablekey = @p_ord_hdrnumber
--									AND 	ref_table = 'orderheader'
--									AND 	ord_hdrnumber = @p_ord_hdrnumber
--									AND 	ref_type = @v_gi_ref3)
--		 END
-- 	 END
--
--	ELSE
--	 BEGIN
--		SELECT	@v_ref_sequence = max(ref_sequence)
--		FROM	completion_referencenumber
--		WHERE	ref_tablekey = @p_ord_hdrnumber
--		AND		ref_table = 'orderheader'
--		AND		ord_hdrnumber = @p_ord_hdrnumber
--
--		If @v_ref_sequence IS NULL
--			Select @v_ref_sequence = 1
--		Else
--			Select @v_ref_sequence = @v_ref_sequence + 1
--
--		INSERT INTO completion_referencenumber
--		(ref_tablekey, ref_type, ref_number, ref_sequence, 
--		 ord_hdrnumber, ref_table, last_updateby, last_updatedate)
--		VALUES
--		(@p_ord_hdrnumber, @v_gi_ref3, @p_refnum3, @v_ref_sequence,
--		 @p_ord_hdrnumber, 'orderheader', @v_tmwuser, getdate())
--	 END
	IF EXISTS (SELECT * FROM referencenumber 
		    WHERE ref_tablekey = @p_ord_hdrnumber
		    AND   ref_table = 'orderheader'
		    AND   ord_hdrnumber = @p_ord_hdrnumber
		    AND   ref_type = @v_gi_ref3)
 	 BEGIN
		IF rtrim(ltrim(@p_refnum3)) <> ''
		 BEGIN
			UPDATE 	referencenumber
			SET	ref_number = @p_refnum3
			WHERE	ref_tablekey = @p_ord_hdrnumber
			AND 	ref_table = 'orderheader'
			AND 	ord_hdrnumber = @p_ord_hdrnumber
			AND 	ref_type = @v_gi_ref3
			AND		ref_sequence = (select min(ref_sequence) from referencenumber
									where ref_tablekey = @p_ord_hdrnumber
									AND 	ref_table = 'orderheader'
									AND 	ord_hdrnumber = @p_ord_hdrnumber
									AND 	ref_type = @v_gi_ref3)
		 END
		ELSE
		 BEGIN
			DELETE FROM referencenumber
			WHERE	ref_tablekey = @p_ord_hdrnumber
			AND		ref_table = 'orderheader'
			AND		ord_hdrnumber = @p_ord_hdrnumber
			AND		ref_type = @v_gi_ref3
			AND		ref_sequence = (select min(ref_sequence) from referencenumber
									where ref_tablekey = @p_ord_hdrnumber
									AND 	ref_table = 'orderheader'
									AND 	ord_hdrnumber = @p_ord_hdrnumber
									AND 	ref_type = @v_gi_ref3)
		 END
 	 END

	ELSE
	 BEGIN
		SELECT	@v_ref_sequence = max(ref_sequence)
		FROM	referencenumber
		WHERE	ref_tablekey = @p_ord_hdrnumber
		AND		ref_table = 'orderheader'
		AND		ord_hdrnumber = @p_ord_hdrnumber

		If @v_ref_sequence IS NULL
			Select @v_ref_sequence = 1
		Else
			Select @v_ref_sequence = @v_ref_sequence + 1

		INSERT INTO referencenumber
		(ref_tablekey, ref_type, ref_number, ref_sequence, 
		 ord_hdrnumber, ref_table, last_updateby, last_updatedate)
		VALUES
		(@p_ord_hdrnumber, @v_gi_ref3, @p_refnum3, @v_ref_sequence,
		 @p_ord_hdrnumber, 'orderheader', @v_tmwuser, getdate())
	 END
--END PTS 56334 SPN
END
--Reference Number 3

--Reference Number 4
If @p_refnum4 IS NOT NULL
--If rtrim(ltrim(@p_refnum4)) <> ''
BEGIN
--BEGIN PTS 56334 SPN
--	IF EXISTS (SELECT * FROM completion_referencenumber 
--		    WHERE ref_tablekey = @p_ord_hdrnumber
--		    AND   ref_table = 'orderheader'
--		    AND   ord_hdrnumber = @p_ord_hdrnumber
--		    AND   ref_type = @v_gi_ref4)
-- 	 BEGIN
--		IF rtrim(ltrim(@p_refnum4)) <> ''
--		 BEGIN
--			UPDATE 	completion_referencenumber
--			SET	ref_number = @p_refnum4
--			WHERE	ref_tablekey = @p_ord_hdrnumber
--			AND 	ref_table = 'orderheader'
--			AND 	ord_hdrnumber = @p_ord_hdrnumber
--			AND 	ref_type = @v_gi_ref4
--			AND		ref_sequence = (select min(ref_sequence) from completion_referencenumber
--									where ref_tablekey = @p_ord_hdrnumber
--									AND 	ref_table = 'orderheader'
--									AND 	ord_hdrnumber = @p_ord_hdrnumber
--									AND 	ref_type = @v_gi_ref4)
--		 END
--		ELSE
--		 BEGIN
--			DELETE FROM completion_referencenumber
--			WHERE	ref_tablekey = @p_ord_hdrnumber
--			AND		ref_table = 'orderheader'
--			AND		ord_hdrnumber = @p_ord_hdrnumber
--			AND		ref_type = @v_gi_ref4
--			AND		ref_sequence = (select min(ref_sequence) from completion_referencenumber
--									where ref_tablekey = @p_ord_hdrnumber
--									AND 	ref_table = 'orderheader'
--									AND 	ord_hdrnumber = @p_ord_hdrnumber
--									AND 	ref_type = @v_gi_ref4)
--		 END
-- 	 END
--
--	ELSE
--	 BEGIN
--		SELECT	@v_ref_sequence = max(ref_sequence)
--		FROM	completion_referencenumber
--		WHERE	ref_tablekey = @p_ord_hdrnumber
--		AND		ref_table = 'orderheader'
--		AND		ord_hdrnumber = @p_ord_hdrnumber
--
--		If @v_ref_sequence IS NULL
--			Select @v_ref_sequence = 1
--		Else
--			Select @v_ref_sequence = @v_ref_sequence + 1
--
--		INSERT INTO completion_referencenumber
--		(ref_tablekey, ref_type, ref_number, ref_sequence, 
--		 ord_hdrnumber, ref_table, last_updateby, last_updatedate)
--		VALUES
--		(@p_ord_hdrnumber, @v_gi_ref4, @p_refnum4, @v_ref_sequence,
--		 @p_ord_hdrnumber, 'orderheader', @v_tmwuser, getdate())
--	 END
	IF EXISTS (SELECT * FROM referencenumber 
		    WHERE ref_tablekey = @p_ord_hdrnumber
		    AND   ref_table = 'orderheader'
		    AND   ord_hdrnumber = @p_ord_hdrnumber
		    AND   ref_type = @v_gi_ref4)
 	 BEGIN
		IF rtrim(ltrim(@p_refnum4)) <> ''
		 BEGIN
			UPDATE 	referencenumber
			SET	ref_number = @p_refnum4
			WHERE	ref_tablekey = @p_ord_hdrnumber
			AND 	ref_table = 'orderheader'
			AND 	ord_hdrnumber = @p_ord_hdrnumber
			AND 	ref_type = @v_gi_ref4
			AND		ref_sequence = (select min(ref_sequence) from referencenumber
									where ref_tablekey = @p_ord_hdrnumber
									AND 	ref_table = 'orderheader'
									AND 	ord_hdrnumber = @p_ord_hdrnumber
									AND 	ref_type = @v_gi_ref4)
		 END
		ELSE
		 BEGIN
			DELETE FROM referencenumber
			WHERE	ref_tablekey = @p_ord_hdrnumber
			AND		ref_table = 'orderheader'
			AND		ord_hdrnumber = @p_ord_hdrnumber
			AND		ref_type = @v_gi_ref4
			AND		ref_sequence = (select min(ref_sequence) from referencenumber
									where ref_tablekey = @p_ord_hdrnumber
									AND 	ref_table = 'orderheader'
									AND 	ord_hdrnumber = @p_ord_hdrnumber
									AND 	ref_type = @v_gi_ref4)
		 END
 	 END

	ELSE
	 BEGIN
		SELECT	@v_ref_sequence = max(ref_sequence)
		FROM	referencenumber
		WHERE	ref_tablekey = @p_ord_hdrnumber
		AND		ref_table = 'orderheader'
		AND		ord_hdrnumber = @p_ord_hdrnumber

		If @v_ref_sequence IS NULL
			Select @v_ref_sequence = 1
		Else
			Select @v_ref_sequence = @v_ref_sequence + 1

		INSERT INTO referencenumber
		(ref_tablekey, ref_type, ref_number, ref_sequence, 
		 ord_hdrnumber, ref_table, last_updateby, last_updatedate)
		VALUES
		(@p_ord_hdrnumber, @v_gi_ref4, @p_refnum4, @v_ref_sequence,
		 @p_ord_hdrnumber, 'orderheader', @v_tmwuser, getdate())
	 END
--END PTS 56334 SPN
END
--Reference Number 4

GO
GRANT EXECUTE ON  [dbo].[update_completion_refnums_sp] TO [public]
GO
