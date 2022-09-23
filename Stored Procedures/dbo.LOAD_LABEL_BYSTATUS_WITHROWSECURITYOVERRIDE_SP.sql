SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Object:  Stored Procedure dbo.LOAD_LABEL_BYSTATUS_WITHROWSECURITYOVERRIDE_SP    Script Date: 8/20/97 1:59:23 PM ******/
create procedure [dbo].[LOAD_LABEL_BYSTATUS_WITHROWSECURITYOVERRIDE_SP] 
@name varchar(20), 
@retired_flag varchar(1),
@RowSecurityOverride varchar(1) as 

-- vjh 42009 added row security override to allow full dropdown population for use in places like Sys Admin

declare	@tmwuser	varchar(255)

if @name = 'COMPANY' and (select gi_string1 from generalinfo where gi_name = 'LegalEntity') = 'Y'
begin
	IF @retired_flag = 'Y'
		SELECT le_shortname name, 
		le_id abbr,
		0 code
		FROM legal_entity 
	
	ELSE
		SELECT le_shortname name, 
		le_id abbr,
		0 code
		FROM legal_entity 
		WHERE IsNull(le_retired, 'N') <> 'Y'
	return
end

if @name = 'REVTYPE1' and upper(left((select gi_string1 from generalinfo where gi_name = 'rowsecurity'),1)) = 'Y'
begin
	--PTS 53557/51570 JJF 20100826 - include all selected values across all tables.
	IF @RowSecurityOverride = 'Y' BEGIN
		SELECT	lbl.name, 
				lbl.abbr, 
				lbl.code 
		FROM	labelfile lbl 
		WHERE 	lbl.labeldefinition = @name
				AND	(	IsNull(lbl.retired, 'N') <> 'Y'
						OR @retired_flag = 'Y'
					)
	END
	ELSE BEGIN
		SELECT	lbl.name, 
				lbl.abbr, 
				lbl.code 
		FROM	labelfile lbl 
				INNER JOIN RowRestrictValidLabels_fn(@name) rsvl on (lbl.abbr = rsvl.abbr or rsvl.abbr = '*')
		WHERE 	lbl.labeldefinition = @name
				AND	(	IsNull(lbl.retired, 'N') <> 'Y'
						OR @retired_flag = 'Y'
					)
	END				
	RETURN
	
	--exec @tmwuser = dbo.gettmwuser_fn
	--
	--IF NOT EXISTS(SELECT * 
	--					FROM UserTypeAssignment
	--					WHERE usr_userid = @tmwuser)
	--	OR
	--EXISTS(SELECT * 
	--			FROM UserTypeAssignment
	--			WHERE usr_userid = @tmwuser
	--					and (uta_type1 = 'UNK'))
	--	OR
	--@RowSecurityOverride = 'Y' BEGIN
	--	IF @retired_flag = 'Y'
	--		SELECT name, 
	--		abbr, 
	--		code 
	--		FROM labelfile 
	--		WHERE 	labeldefinition = @name
	--	ELSE
	--		SELECT name, 
	--		abbr, 
	--		code 
	--		FROM labelfile 
	--		WHERE 	labeldefinition = @name AND
	--			IsNull(retired, 'N') <> 'Y'
	--	return
	--END
	--
	--
	--IF @retired_flag = 'Y'
	--	SELECT name, 
	--	abbr, 
	--	code 
	--	FROM labelfile 
	--	WHERE 	labeldefinition = @name
	--		and (abbr = 'UNK' or abbr in (select uta_type1 from usertypeassignment where usr_userid = dbo.gettmwuser_fn()))
	--
	--ELSE
	--	SELECT name, 
	--	abbr, 
	--	code 
	--	FROM labelfile 
	--	WHERE 	labeldefinition = @name AND
	--		IsNull(retired, 'N') <> 'Y'
	--		and (abbr = 'UNK' or abbr in (select uta_type1 from usertypeassignment where usr_userid = dbo.gettmwuser_fn()))
	--return
	
	--END
	--PTS 53557/51570 JJF 20100826 - include all selected values across all tables.
end

--PTS 57071 JJF 20110705
if @name = 'REVTYPE1' and upper(left((select gi_string1 from generalinfo where gi_name = 'labelfilterrevtype1'),1)) = 'Y'
begin
	--PTS 58406 JJF 20110811
	IF @RowSecurityOverride = 'Y' BEGIN
		SELECT	lbl.name, 
				lbl.abbr, 
				lbl.code 
		FROM	labelfile lbl 
		WHERE 	lbl.labeldefinition = @name
				AND	(	IsNull(lbl.retired, 'N') <> 'Y'
						OR @retired_flag = 'Y'
					)
	END
	ELSE BEGIN
	--END PTS 58406 JJF 20110811
		exec @tmwuser = dbo.gettmwuser_fn
		
		IF NOT EXISTS	(	SELECT	*
							FROM	UserTypeAssignment
							WHERE	usr_userid = @tmwuser
						) BEGIN
			--OR EXISTS	(	SELECT	* 
			--				FROM	UserTypeAssignment
			--				WHERE	usr_userid = @tmwuser
			--						and (uta_type1 = 'UNK')
			--			) BEGIN

			IF @retired_flag = 'Y' BEGIN
				SELECT	name, 
						abbr, 
						code 
				FROM	labelfile 
				WHERE 	labeldefinition = @name
			END
			ELSE BEGIN
				SELECT	name, 
						abbr, 
						code 
				FROM	labelfile 
				WHERE 	labeldefinition = @name 
						AND IsNull(retired, 'N') <> 'Y'
			END
			
			RETURN
		END
		
		
		IF @retired_flag = 'Y' BEGIN
			SELECT	name, 
					abbr, 
					code 
			FROM	labelfile 
			WHERE 	labeldefinition = @name
					and	(	abbr = 'UNK' 
							or abbr in	(	select	uta_type1 
											from	usertypeassignment 
											where	usr_userid = dbo.gettmwuser_fn()
										)
						)
		END
		ELSE BEGIN
			SELECT	name, 
					abbr, 
					code 
			FROM	labelfile 
			WHERE 	labeldefinition = @name 
					AND IsNull(retired, 'N') <> 'Y'
					and	(	abbr = 'UNK' 
							or abbr in	(	select	uta_type1 
											from	usertypeassignment 
											where	usr_userid = dbo.gettmwuser_fn()
										)
						)
		END
		
		RETURN
	END	
	
end
--END PTS 57071 JJF 20110705


if @name = 'TERMINAL' and upper(left((select gi_string1 from generalinfo where gi_name = 'RestTerminalDropDown'),1)) = 'Y'
begin
	exec @tmwuser = dbo.gettmwuser_fn

	IF NOT EXISTS(SELECT * 
						FROM UserTypeAssignment
						WHERE usr_userid = @tmwuser)
		OR
	EXISTS(SELECT * 
				FROM UserTypeAssignment
				WHERE usr_userid = @tmwuser
						and (uta_type1 = 'UNK')) BEGIN
		IF @retired_flag = 'Y'
			SELECT name, 
			abbr, 
			code 
			FROM labelfile 
			WHERE 	labeldefinition = @name
		ELSE
			SELECT name, 
			abbr, 
			code 
			FROM labelfile 
			WHERE 	labeldefinition = @name AND
				IsNull(retired, 'N') <> 'Y'
		return
	END


	IF @retired_flag = 'Y'
		SELECT name, 
		abbr, 
		code 
		FROM labelfile 
		WHERE 	labeldefinition = @name
			and (abbr = 'UNK' or abbr in (select uta_type1 from usertypeassignment where usr_userid = dbo.gettmwuser_fn()))

	ELSE
		SELECT name, 
		abbr, 
		code 
		FROM labelfile 
		WHERE 	labeldefinition = @name AND
			IsNull(retired, 'N') <> 'Y'
			and (abbr = 'UNK' or abbr in (select uta_type1 from usertypeassignment where usr_userid = dbo.gettmwuser_fn()))
	return
end

IF @retired_flag = 'Y'
	SELECT name, 
	abbr, 
	code 
	FROM labelfile 
	WHERE 	labeldefinition = @name

ELSE
	SELECT name, 
	abbr, 
	code 
	FROM labelfile 
	WHERE 	labeldefinition = @name AND
		IsNull(retired, 'N') <> 'Y'

GO
GRANT EXECUTE ON  [dbo].[LOAD_LABEL_BYSTATUS_WITHROWSECURITYOVERRIDE_SP] TO [public]
GO
