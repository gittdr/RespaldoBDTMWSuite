SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[create_completion_rba_refnum_sp]	 
@p_ord_number			char(12),
@p_new_ord_refnum		char(12),
@p_new_ord_hdrnumber	int,
@p_new_ord_status		char(12)

AS 

/**
 * 
 * NAME:
 * create_completion_rba_refnum_sp
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
 * PARAMETERS: NONE
 *
 * REVISION HISTORY:
 * 3/30/2007.01 ? PTS33397 - Dan Hudec ? Created Procedure
 * 03/31/2011 PTS 56334 SPN now on we are using referencenumber table instead of completion_referencenumber
 *
 **/

DECLARE	@v_ref_sequence			int,
		@v_ord_hdrnumber		int,
		@v_tmwuser				varchar(255),
		@v_old_ord_hdrnumber	int,
		@v_temp_refnum			varchar(50)

exec gettmwuser @v_tmwuser output

SELECT	@v_ord_hdrnumber = ord_hdrnumber
FROM	completion_orderheader
WHERE	ord_number = @p_ord_number

--BEGIN PTS 56334 SPN
--SELECT	@v_ref_sequence = max(ref_sequence)
--FROM	completion_referencenumber
--WHERE	ref_tablekey = @v_ord_hdrnumber
--AND		ref_table = 'orderheader'
--AND		ord_hdrnumber = @v_ord_hdrnumber
SELECT @v_ref_sequence = max(ref_sequence)
  FROM referencenumber
 WHERE ref_tablekey = @v_ord_hdrnumber
   AND ref_table = 'orderheader'
   AND ord_hdrnumber = @v_ord_hdrnumber
--END PTS 56334 SPN

If @v_ref_sequence IS NULL
	Select @v_ref_sequence = 1
Else
	Select @v_ref_sequence = @v_ref_sequence + 1

--BEGIN PTS 56334 SPN
--INSERT INTO completion_referencenumber
--(ref_tablekey, ref_type, ref_number, ref_sequence, 
-- ord_hdrnumber, ref_table, last_updateby, last_updatedate)
--VALUES
--(@v_ord_hdrnumber, 'RBA', @p_new_ord_refnum, @v_ref_sequence,
-- @v_ord_hdrnumber, 'orderheader', @v_tmwuser, getdate())
--END PTS 56334 SPN

INSERT INTO referencenumber
(ref_tablekey, ref_type, ref_number, ref_sequence, 
 ord_hdrnumber, ref_table, last_updateby, last_updatedate)
VALUES
(@v_ord_hdrnumber, 'RBA', @p_new_ord_refnum, @v_ref_sequence,
 @v_ord_hdrnumber, 'orderheader', @v_tmwuser, getdate())

SELECT	@v_temp_refnum = 'W:RBA Refnum:' + @p_new_ord_refnum
exec notes_add_sp 'orderheader', @v_ord_hdrnumber, @v_temp_refnum, 'S', 'N', 'I'

SELECT	@v_temp_refnum = 'W:PBA Refnum: ' + @p_ord_number
exec notes_add_sp 'orderheader', @p_new_ord_hdrnumber, @v_temp_refnum, 'S', 'N', 'I'

DECLARE	@v_cur_ref_sequence	int,
		@v_max_ref_sequence int,
		@v_cur_refnum		varchar(30),
		@v_cur_reftype		varchar(6)

--BEGIN PTS 56334 SPN
--SELECT	@v_cur_ref_sequence = min(ref_sequence)
--FROM	completion_referencenumber
--WHERE	ref_tablekey = @v_ord_hdrnumber
--and		ref_table = 'orderheader'
SELECT @v_cur_ref_sequence = min(ref_sequence)
  FROM referencenumber
 WHERE ref_tablekey = @v_ord_hdrnumber
   and ref_table = 'orderheader'

--SELECT	@v_max_ref_sequence = max(ref_sequence)
--FROM	completion_referencenumber
--WHERE	ref_tablekey = @v_ord_hdrnumber
--and		ref_table = 'orderheader'
SELECT @v_max_ref_sequence = max(ref_sequence)
  FROM referencenumber
 WHERE ref_tablekey = @v_ord_hdrnumber
   and ref_table = 'orderheader'
--END PTS 56334 SPN

--Refnum cleanup on copyorderforrebill
If @p_new_ord_status = 'INC'
	RETURN

WHILE @v_cur_ref_sequence <= @v_max_ref_sequence
 BEGIN
	--BEGIN PTS 56334 SPN
	--SELECT	@v_cur_refnum = ref_number,
	--		@v_cur_reftype = ref_type
	--FROM	completion_referencenumber
	--WHERE	ref_tablekey = @v_ord_hdrnumber
	--and		ref_table = 'orderheader'
	--and		ref_sequence = @v_cur_ref_sequence
	SELECT @v_cur_refnum = ref_number
	     , @v_cur_reftype = ref_type
	  FROM referencenumber
	 WHERE ref_tablekey = @v_ord_hdrnumber
	   and ref_table = 'orderheader'
	   and ref_sequence = @v_cur_ref_sequence
	--END PTS 56334 SPN

	If @v_cur_reftype <> 'RBA' and @v_cur_reftype <> 'PBA'
	 BEGIN
		--BEGIN PTS 56334 SPN
		--IF not exists (SELECT * FROM completion_referencenumber
		--			   WHERE ref_tablekey = @p_new_ord_hdrnumber
		--			   and ref_table = 'orderheader' and ref_type = @v_cur_reftype
		--			   and ref_number = @v_cur_refnum) 
		IF NOT EXISTS (SELECT *
				 FROM referencenumber
				WHERE ref_tablekey = @p_new_ord_hdrnumber
				  and ref_table = 'orderheader' and ref_type = @v_cur_reftype
				  and ref_number = @v_cur_refnum
				)
		--END PTS 56334 SPN
		 BEGIN
			--BEGIN PTS 56334 SPN
			--SELECT	@v_ref_sequence = max(ref_sequence)
			--FROM	completion_referencenumber
			--WHERE	ref_tablekey = @p_new_ord_hdrnumber
			--AND		ref_table = 'orderheader'
			--AND		ord_hdrnumber = @p_new_ord_hdrnumber
			SELECT @v_ref_sequence = max(ref_sequence)
			  FROM referencenumber
			 WHERE ref_tablekey = @p_new_ord_hdrnumber
			   AND ref_table = 'orderheader'
			   AND ord_hdrnumber = @p_new_ord_hdrnumber
			--END PTS 56334 SPN

			If @v_ref_sequence IS NULL
				Select @v_ref_sequence = 1
			Else
				Select @v_ref_sequence = @v_ref_sequence + 1

			--BEGIN PTS 56334 SPN
			--INSERT INTO completion_referencenumber
			--(ref_tablekey, ref_type, ref_number, ref_sequence, 
			-- ord_hdrnumber, ref_table, last_updateby, last_updatedate)
			--VALUES
			--(@p_new_ord_hdrnumber, @v_cur_reftype, @v_cur_refnum, @v_ref_sequence,
			-- @p_new_ord_hdrnumber, 'orderheader', @v_tmwuser, getdate())
			--END PTS 56334 SPN

			INSERT INTO referencenumber
			(ref_tablekey, ref_type, ref_number, ref_sequence, 
			 ord_hdrnumber, ref_table, last_updateby, last_updatedate)
			VALUES
			(@p_new_ord_hdrnumber, @v_cur_reftype, @v_cur_refnum, @v_ref_sequence,
			 @p_new_ord_hdrnumber, 'orderheader', @v_tmwuser, getdate())
		 END
	 END

	--BEGIN PTS 56334 SPN
	--SELECT	@v_cur_ref_sequence = min(ref_sequence)
	--FROM	completion_referencenumber
	--WHERE	ref_tablekey = @v_ord_hdrnumber
	--and		ref_table = 'orderheader'
	--and		ref_sequence > @v_cur_ref_sequence
	SELECT @v_cur_ref_sequence = min(ref_sequence)
	  FROM referencenumber
	 WHERE ref_tablekey = @v_ord_hdrnumber
	   and ref_table = 'orderheader'
	   and ref_sequence > @v_cur_ref_sequence
	--END PTS 56334 SPN
 END
GO
GRANT EXECUTE ON  [dbo].[create_completion_rba_refnum_sp] TO [public]
GO
