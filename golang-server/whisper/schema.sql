create table users (
    id                      serial          not null primary key,
    name                    text            not null,
    user_id                 text            not null,
    email                   text            not null,
    profile                 text,
    public_key              text            not null,
    encrypted_private_key   text            not null,
    hash_password           char(44)        not null,
    hash_pin                char(44)        not null,
    salt                    char(44)        not null,
    created_at              timestamptz     default now(),
    updated_at              timestamptz     default now()
);

create table auths (
    id          serial      not null primary key,
    uid         integer     references users (id) on delete cascade,
    token       char(64)    unique,
    created_at  timestamptz default now(),
    expired_at  timestamptz not null
);

create table friends (
    id          serial      not null primary key,
    inviter     integer     references users(id) on delete cascade,
    invitee     integer     references users(id) on delete cascade,
    accepted    boolean     default false,
    created_at  timestamptz default now(),
    updated_at  timestamptz default now()
);

create table channels(
    id          serial      not null primary key,
    friend_id   int         references friends(id) on delete cascade,
    key_encrypted_by_inviter_key    text not null,
    key_encrypted_by_invitee_key    text not null,
    created_at  timestamptz default now()
);

create table messages(
    id                  serial      not null primary key,
    channel_id          int         not null references channels(id) on delete cascade,
    sender              int         references users(id),
    encrypted_message   text        not null,
    created_at          timestamptz default now()
);

create view view_friend_lists as 
select
        t1.*,
        coalesce(channels.id, -1) as channel_id
from (
    select f.id as friend_id,
           f.inviter + f.invitee - u.id as me,
           u.id as uid,
           u.user_id,
           u.name,
           u.profile,
           u.public_key
    from friends as f,
         users as u
    where u.id = f.inviter or u.id=f.invitee
)t1
left join channels
on t1.friend_id = channels.friend_id;

create view view_friend_channels as
    select 
        c.id as channel_id, 
        key_encrypted_by_inviter_key, 
        key_encrypted_by_invitee_key, 
        inviter, 
        invitee 
    from 
        channels as c, 
        friends as f 
    where 
        c.friend_id = f.id and 
        f.accepted = true;