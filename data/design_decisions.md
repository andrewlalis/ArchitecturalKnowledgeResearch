# Design Decisions

This document contains the basic definitions of each type of Architectural Design Decision, as they will be used to categorize emails and issues when filtering content.



## Architectural Knowledge

A catch-all term under which any of the below definitions falls. If content is categorized as any type of design decision mentioned in this document, it is also implicitly a type of architectural knowledge.

## Structural

Decisions that lead to the creation of subsystems, layers, partitions, and components in some view of the architecture.

## Behavioral

Decisions that are related to how the elements of a system interact to provide functionality or to satisfy some non-functional requirement (quality attribute), or connectors.

Examples:

> The proposed design is:
> * Assign each host T random tokens.
> * A partition is assigned to a host for each of its tokens, where the
> partition is defined by the interval between a token and the previous token on the ring.

> We're starting to see client protocol limitations impact performance, and so we'd like to evolve the protocol to remove the limitations.

## Property

Decisions that establish an enduring trait or quality of the system. Property decisions can be design rules or guidelines (when expressed positively) or design constraints (when expressed negatively).

Examples:

> As the first aspect of the discussion, we should probably state the overall goals and scoping for this effort:
> * An alternative authentication mechanism to Kerberos for user authentication
> * A broader capability for integration into enterprise identity and SSO solutions
> * Possibly the advertisement/negotiation of available authentication mechanisms
> * Backward compatibility for the existing use of Kerberos
> * No (or minimal) changes to existing Hadoop tokens (delegation, job, block access, etc)
> * Pluggable authentication mechanisms across: RPC, REST and webui enforcement points
> * Continued support for existing authorization policy/ACLs, etc
> * Keeping more fine grained authorization policies in mind - like attribute based access control



## Ban

Decisions which state that some elements will not appear in the system's design or implementation.

Examples:

> I'd like to propose that we retroactively classify materialized views as an experimental feature, disable them by default, and require users to enable them through a config setting before using.

## Technology

Decisions involving a choice of certain technologies for a system, such as programming languages, databases, messaging systems, or frameworks.

Examples:

> Should we broaden the focus to using and running Cassandra in Kubernetes in general? CEP 2 Kubernetes Operator

## Tool

Decisions that involve tools that developers use, such as online issue and project management boards, IDEs, or supplementary programs like package managers.

## Process

Decisions about the overarching process developers must follow when implementing the software.

Examples:

> Reviewers should be able to suggest when experimental is warranted, and conversation on dev+jira to justify when it's transitioned from experimental to stable?