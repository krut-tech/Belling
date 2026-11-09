-- Staff management for Belling. Run once in Supabase SQL editor.
create or replace function public.list_staff(p_business text)
returns table (user_id uuid, email text, role text)
language plpgsql security definer set search_path = '' as $$
begin
  if not app_private.has_role(p_business, array['owner','manager']) then
    raise exception 'not allowed';
  end if;
  return query
    select m.user_id, u.email::text, m.role
    from public.business_members m
    join auth.users u on u.id = m.user_id
    where m.business_id = p_business
    order by m.created_at;
end $$;

create or replace function public.add_staff_by_email(p_business text, p_email text, p_role text)
returns void
language plpgsql security definer set search_path = '' as $$
declare v_uid uuid;
begin
  if not app_private.has_role(p_business, array['owner']) then
    raise exception 'only the owner can add staff';
  end if;
  if p_role not in ('manager','cashier','accountant') then
    raise exception 'invalid role';
  end if;
  select id into v_uid from auth.users where lower(email) = lower(trim(p_email)) limit 1;
  if v_uid is null then
    raise exception 'user not found: they must sign in to Belling once first';
  end if;
  insert into public.business_members (business_id, user_id, role)
  values (p_business, v_uid, p_role)
  on conflict (business_id, user_id) do update set role = excluded.role
  where public.business_members.role <> 'owner';
end $$;

create or replace function public.remove_staff(p_business text, p_user uuid)
returns void
language plpgsql security definer set search_path = '' as $$
begin
  if not app_private.has_role(p_business, array['owner']) then
    raise exception 'only the owner can remove staff';
  end if;
  delete from public.business_members
  where business_id = p_business and user_id = p_user and role <> 'owner';
end $$;

revoke all on function public.list_staff(text) from public, anon;
revoke all on function public.add_staff_by_email(text, text, text) from public, anon;
revoke all on function public.remove_staff(text, uuid) from public, anon;
grant execute on function public.list_staff(text) to authenticated;
grant execute on function public.add_staff_by_email(text, text, text) to authenticated;
grant execute on function public.remove_staff(text, uuid) to authenticated;
