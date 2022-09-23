SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[get_consolidated_list_sp]	@p_ord_hdrnumber int, 
											@p_consolidated_list varchar(255) OUTPUT

AS

BEGIN

DECLARE	@v_mov_number			int,
		@v_cur_ord_hdrnumber	int,
		@v_max_ord_hdrnumber	int,
		@v_cur_ord_number		char(12),
		@v_first_time			char(1)

SELECT	@v_mov_number = mov_number
FROM	orderheader
WHERE	ord_hdrnumber = @p_ord_hdrnumber

SELECT	@v_first_time = 'Y'

SELECT	@p_consolidated_list = ''

IF (SELECT count(*) FROM orderheader WHERE mov_number = @v_mov_number) > 1
 BEGIN

	SELECT	@v_cur_ord_hdrnumber = min(ord_hdrnumber),
			@v_max_ord_hdrnumber = max(ord_hdrnumber)
	FROM	orderheader
	WHERE	ord_hdrnumber <> @p_ord_hdrnumber
	 AND	mov_number = @v_mov_number
     AND	ord_hdrnumber <> 0

	SELECT	@v_cur_ord_number = ord_number
	FROM	orderheader
	WHERE	ord_hdrnumber = @v_cur_ord_hdrnumber

	WHILE 1 = 1
	 BEGIN
		If @v_first_time = 'Y'
			SELECT @p_consolidated_list = rtrim(ltrim(@v_cur_ord_number))
		Else
			SELECT @p_consolidated_list = @p_consolidated_list + ', ' + rtrim(ltrim(@v_cur_ord_number))

		IF @v_cur_ord_hdrnumber = @v_max_ord_hdrnumber
			BREAK
		ELSE
		 BEGIN
			SELECT	@v_cur_ord_hdrnumber = ord_hdrnumber
			FROM	orderheader
			WHERE	mov_number = @v_mov_number
			AND		ord_hdrnumber <> @p_ord_hdrnumber
			AND		ord_hdrnumber > @v_cur_ord_hdrnumber

			SELECT	@v_cur_ord_number = ord_number
			FROM	orderheader
			WHERE	ord_hdrnumber = @v_cur_ord_hdrnumber
		 END

		SELECT	@v_first_time = 'N'
	 END
 END
END

GO
GRANT EXECUTE ON  [dbo].[get_consolidated_list_sp] TO [public]
GO
