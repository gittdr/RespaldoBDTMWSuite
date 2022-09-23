SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[get_ord_terminal_pref]  (@newordnbr int,@INIOrderIDFormatFlag char(1))
AS
/*
Proc not working ro TERMINALPREFIX7 option DPETE PTS 53587
*/
DECLARE @s_newordnbr varchar(12),
	@z2 char(2), 
	@z3 char(3), 
	@z4 char(4),
	@ll_Mod int,
	@ll_Div int,
	@ll_Mod2 int,
	@ll_Div2 int,
	@ltr char(1),
	@ltr1 char(1),
	@ltr2 char(1),
	@ls_letter_list varchar(30),
	@ls_mod varchar(12),
   @GI_OrderIDFormat varchar(60)


select @INIOrderIDFormatFlag = isnull(@INIOrderIDFormatFlag,'')

/* terminal prefix 7 is one char of revtype followed by a 7 digit number that repeats after 9999999 Per PTS34451
   (I see code in OE that deals with order nubmers 10000000 AND 100000000 not dealt with here   */
If @INIOrderIDFormatFlag  = 'T'  -- TERMINALPREFIX7
  BEGIN
     select @newordnbr = (@newordnbr % 10000000)
     --If @newordnbr < 10000000
       BEGIN
        select @s_NewOrdNbr = convert(varchar(12),@newordnbr)
        if datalength(@s_NewOrdNbr) < 7 
         begin
            select @s_NewOrdNbr = replicate('0', 7 - datalength(@s_NewOrdNbr)) + @s_NewOrdNbr
         end
        goto result
       END
    -- ELSE
     -- BEGIN
             

    --  END
  END
If @INIOrderIDFormatFlag = '9'   -- TERMINALPREFIX9
   begin
     if @newordnbr > 0 and (@newordnbr % 1000000000) = 0 
        select @newordnbr = 1000000000
     else
		select @newordnbr = (@newordnbr % 1000000000)
     select @s_NewOrdNbr = convert(varchar(12),@newordnbr)
     if datalength(@s_NewOrdNbr) < 9 select @s_NewOrdNbr = replicate('0', 9 - datalength(@s_NewOrdNbr)) + @s_NewOrdNbr
     goto result
   end

If @INIOrderIDFormatFlag = '6'   -- PTS 94043 TERMINALPREFIX6
   begin
	  select	@ls_letter_list = 'ABCDEFGHJKLMNPQRSTUVWXYZ'
	  select @newordnbr = (@newordnbr % 10000000)
	  If @newordnbr >= 0 and @newordnbr <= 999999
       BEGIN
        select @s_NewOrdNbr = convert(varchar(12),@newordnbr)
        if datalength(@s_NewOrdNbr) <= 6 
         begin
            select @s_NewOrdNbr = replicate('0', 6 - datalength(@s_NewOrdNbr)) + @s_NewOrdNbr
            goto result
         end
       END
      else if @newordnbr >= 1000000 and @newordnbr <= 3399999
		BEGIN
			select @ll_Mod = (@newordnbr % 100000)
			select @ll_Div = convert(int, (@newordnbr / 100000)) - 9

			select @ltr = substring(@ls_letter_list, @ll_div, 1)
		
			select	@ls_mod = convert(varchar(12), @ll_mod)
			select	@ls_mod = replicate('0', 5 - datalength(@ls_mod)) + @ls_mod
			select	@s_NewOrdNbr = @ltr + @ls_mod

			goto result
		END
	  else if @newordnbr >= 3400000 and @newordnbr <= 9159999
		BEGIN
			select @ll_Mod = (@newordnbr % 10000)
			select @ll_Div = convert(int, (@newordnbr / 10000)) - 340
			select @ll_Mod2 = (@ll_Div % 24)
			select	@ltr1 = substring(@ls_letter_list, @ll_mod2 + 1, 1)
			select @ll_Div2 = convert(int, (@ll_Div / 24 ))
			select	@ltr2 = substring(@ls_letter_list, @ll_div2 + 1, 1)
			select	@ls_mod = convert(varchar(12), @ll_mod)
			select	@ls_mod = replicate('0', 4 - datalength(@ls_mod)) + @ls_mod
			select 	@s_NewOrdNbr = @ltr2 + @ltr1 + @ls_mod
			goto result
		END
	  else if @newordnbr >= 9160000 and @newordnbr <= 10000000
		BEGIN
			select @ll_mod = (@newordnbr % 1000)

			select	@ls_mod = convert(varchar(12), @ll_mod)
			select	@ls_mod = replicate('0', 3 - datalength(@ls_mod)) + @ls_mod
			select	@s_newordnbr = @ls_mod
			select @ll_div = convert(int, (@newordnbr / 1000)) - 9160
			select @ll_mod = (@ll_div % 24)

			select	@ltr1 = substring(@ls_letter_list, @ll_mod + 1, 1)
		
			select @s_newordnbr = @ltr1 + @s_newordnbr
			select @ll_div = convert(int, (@ll_div / 24))
			select @ll_mod = (@ll_div % 24)

			select	@ltr1 = substring(@ls_letter_list, @ll_mod + 1, 1)
		
			select @s_newordnbr = @ltr1 + @s_newordnbr
			select @ll_div = convert(int, (@ll_div/ 24))

			select	@ltr2 = substring(@ls_letter_list, @ll_div + 1, 1)
		
			select @s_newordnbr = @ltr2 + @s_newordnbr
			goto result
		END
   end	--end 94043

select @z2 = '00', @z3 = '000', @z4 = '0000'

-- If ordHdrnumber is between 0 and 999999 leave alone
-- number repeats after 1 mil
if (@newordnbr % 1000000) <> 0 and @newordnbr > 1000000 
begin
	select @newordnbr = (@newordnbr % 1000000) 

	--vmj1+	PTS 14427	06/03/2002	Still need the alpha-conversion logic, even if it's > 1,000,000 (commented out)..
--	goto result
	--vmj1-
end

--vmj1+	Handle multiples of 1000000..
if (@newordnbr % 1000000) = 0
	and @NewOrdNbr > 0

	select	@NewOrdNbr = 1000000
--vmj1-


-- 00000 - 99999 converts to 00000 to 99999
If @newordnbr >= 0 and @newordnbr <= 99999 
begin
	select @s_newordnbr = convert(varchar(12), @newordnbr)

	--vmj1+	Need to pad zeroes..
	select	@s_NewOrdNbr = replicate('0', 5 - datalength(@s_NewOrdNbr)) + @s_NewOrdNbr
	--vmj1-

	goto result
end


--vmj1+	@ls_letter_list contains the list of letters used in Alpha-converted order numbers.  We use all letters except 
--'I' and 'O' because of their potential confusion with 1 and 0..
select	@ls_letter_list = 'ABCDEFGHJKLMNPQRSTUVWXYZ'
--vmj1-


-- 100000 to 339999 converts to A0000 to Z9999
If @newordnbr >= 100000 and @newordnbr <= 339999
begin
	select @ll_Mod = (@newordnbr % 10000)
	select @ll_Div = convert(int, (@newordnbr / 10000)) - 9

	--vmj1+	The permanent table ord_terminal_pref is not needed..
	select @ltr = substring(@ls_letter_list, @ll_div, 1)
--	select @ltr = let from ord_terminal_pref where li = @ll_Div

	--Pad zeroes; for example, return 'A0014' instead of 'A14'..
	select	@ls_mod = convert(varchar(12), @ll_mod)
	select	@ls_mod = replicate('0', 4 - datalength(@ls_mod)) + @ls_mod
	select	@s_NewOrdNbr = @ltr + @ls_mod
---- select @s_newordnbr = @ltr + Convert(varchar(4), @ll_Mod, @z4)
--	select @s_newordnbr = @ltr + Convert(varchar(4), @ll_Mod)
	--vmj1-

	goto result
end


-- 340000 to 915999 converts to AA000 to ZZ999	
If @newordnbr >= 340000 and @newordnbr <= 915999
begin
	select @ll_Mod = (@newordnbr % 1000)
	select @ll_Div = convert(int, (@newordnbr / 1000)) - 340
	select @ll_Mod2 = (@ll_Div % 24)

	--vmj1+
	select	@ltr1 = substring(@ls_letter_list, @ll_mod2 + 1, 1)
--	select @ltr1 = let from ord_terminal_pref where li = (@ll_Mod2 + 1)
	--vmj1-

	select @ll_Div2 = convert(int, (@ll_Div / 24 ))

	--vmj1+
	select	@ltr2 = substring(@ls_letter_list, @ll_div2 + 1, 1)
--	select @ltr2 = let from ord_terminal_pref where li = (@ll_Div2 + 1)

	select	@ls_mod = convert(varchar(12), @ll_mod)
	select	@ls_mod = replicate('0', 3 - datalength(@ls_mod)) + @ls_mod
	select 	@s_NewOrdNbr = @ltr2 + @ltr1 + @ls_mod
---- select @s_newordnbr = @ltr2 + @ltr1 + Convert(varchar(12), @ll_Mod,@z3)
--	select @s_newordnbr = @ltr2 + @ltr1 + Convert(varchar(12), @ll_Mod)
	--vmj1-

	goto result
end


-- 916000 to 1000000 converts to AAA00 to BMA00	
If @newordnbr >= 916000 and @newordnbr <= 1000000
begin
	select @ll_mod = (@newordnbr % 100)

	--vmj1+
	select	@ls_mod = convert(varchar(12), @ll_mod)
	select	@ls_mod = replicate('0', 2 - datalength(@ls_mod)) + @ls_mod
	select	@s_newordnbr = @ls_mod
---- select @s_newordnbr = convert(varchar(2), @ll_mod, @z2)
--	select @s_newordnbr = convert(varchar(2), @ll_mod)
	--vmj1-

	select @ll_div = convert(int, (@newordnbr / 100)) - 9160
	select @ll_mod = (@ll_div % 24)

	--vmj1+
	select	@ltr1 = substring(@ls_letter_list, @ll_mod + 1, 1)
--	select @ltr1 = let from ord_terminal_pref where li = (@ll_Mod + 1)
	--vmj1-

	select @s_newordnbr = @ltr1 + @s_newordnbr
	select @ll_div = convert(int, (@ll_div / 24))
	select @ll_mod = (@ll_div % 24)

	--vmj1+
	select	@ltr1 = substring(@ls_letter_list, @ll_mod + 1, 1)
--	select @ltr1 = let from ord_terminal_pref where li = (@ll_Mod + 1)
	--vmj1-

	select @s_newordnbr = @ltr1 + @s_newordnbr
	select @ll_div = convert(int, (@ll_div/ 24))

	--vmj1+
	select	@ltr2 = substring(@ls_letter_list, @ll_div + 1, 1)
--	select @ltr2 = let from ord_terminal_pref where li = (@ll_div + 1)
	--vmj1-

	select @s_newordnbr = @ltr2 + @s_newordnbr
end


result:
select @s_newordnbr
GO
GRANT EXECUTE ON  [dbo].[get_ord_terminal_pref] TO [public]
GO
